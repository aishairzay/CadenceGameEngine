import * as fcl from "@onflow/fcl";
import { startCode, tickCode } from "./Cadence";
const t = require('@onflow/types');


const replaceImports = (code, gameAddress) => {
  // replace lines that look like `import "GameLevels"` with "import GameLevels from GAME_ADDRESS"
  return code.replace(/import\s+"([^"]+)"/g, (match, p1) => {
    return `import ${p1} from ${gameAddress}`;
  })
};

class Game {
  constructor(network, contractAddress, contractName, levelName, callback) {
    this.contractAddress = contractAddress;
    this.contractName = contractName;
    this.levelName = levelName;
    this.curEvent = null;
    this.tickCount = 1;
    this.tickPredictions = {}; // Map of tick count to prediction, so we can run the game early on behalf of the player
    this.tickResults = {}; // Map of tick count to result, so we can replay or rewind the game
    this.lastTickTime = null;
    this.predictionLength = 2;
    this.lastExecutedTick = 0;
    this.alreadyExecuting = -1;
    this.callback = callback;
    this.tickToEvent = {};
    if (network === "emulator") {
      fcl.config().put("accessNode.api", "http://localhost:8888");
    } else if (network === "testnet") {
      fcl.config().put("accessNode.api", "https://testnet.onflow.org");
    } else if (network === "mainnet") {
      fcl.config().put("accessNode.api", "https://mainnet.onflow.org");
    } else {
      fcl.config().put("accessNode.api", network)
    }
  }

  async start() {
    try {
      // Get the contract code in order to pull out the game engine contract address
      const account = await fcl.account(fcl.withPrefix(this.contractAddress));
      const contractCode = account.contracts[this.contractName];
      // find the line in contract code where the text `import "GameEngine"` is
      const gameEngineImportLine = contractCode.split("\n").find((line) => {
        return line.includes(`import GameEngine`)
      })
      // extract the game engine address from the import line
      const gameEngineAddress = gameEngineImportLine.split("from")[1].trim();
      this.gameEngineAddress = gameEngineAddress;
      
      let lastResult = await fcl.send([
        fcl.script`${replaceImports(startCode, this.gameEngineAddress)}`,
        fcl.args([
          fcl.arg(this.contractAddress, t.Address),
          fcl.arg(this.contractName, t.String),
          fcl.arg(this.levelName, t.String)
        ])
      ]).then(fcl.decode)

      this.tickResults[0] = lastResult;

      this.callback(lastResult)

      this.executeTickAPILoop();
      this.executeGameLoop();

    } catch (e) {
      console.log('Reached an error', e)
    }

  }

  async executeTickAPILoop() {
    setInterval(() => {
      if (this.tickCount <= this.lastExecutedTick || !this.tickResults[this.tickCount - 1]) {
        return;
      }
      const lastResult = this.tickResults[this.tickCount - 1];
      const eventToSend = this.tickToEvent[this.tickCount]

      if (!eventToSend) {
        return
      }

      if (this.alreadyExecuting === lastResult.tickCount) {
        return;
      }
      this.alreadyExecuting = lastResult.tickCount;
  
      this.tickPromise = this.tick(lastResult, eventToSend).then((result) => {
        const mostRecentResult = result[eventToSend || "NONE"]
        const tick = mostRecentResult.tickCount

        // tick is tick

        // set the predictions at our current tick to tickPredictions
        this.tickPredictions[tick] = result;
        this.tickResults[tick] = mostRecentResult;
        this.lastExecutedTick = parseInt(tick);
      })
    }, 10);
  }

  async executeGameLoop() {
    // assume 300ms per tick for now for testing
    const timePerTick = 300;

    while (true) {

      // Wait the tick time and then call the callback with the new game state
      await new Promise((resolve) => {
        setTimeout(() => {
          resolve();
        }, timePerTick)
      })

      const curEventCode = this.curEvent ? this.curEvent : "NONE";
      this.curEvent = null;

      //console.log('Tick count is', this.tickCount, 'last executed tick is', this.lastExecutedTick, 'prediction length is', this.predictionLength)

      // We should have all predictions for this tick. Grab the next prediction
      // that corresponds with the user's input.

      this.tickToEvent[this.tickCount] = curEventCode;

      // Sleep until we are caught up/should have a result for this tick
      while (this.tickCount > this.lastExecutedTick + this.predictionLength) {
        await new Promise((resolve) => {
          setTimeout(() => {
            resolve();
          }, 10)
        })
      }

      let key = []
      let curPredictionTick = null

      while (this.lastExecutedTick === 0 && !this.tickPredictions[1]) {
        await new Promise((resolve) => {
          setTimeout(() => {
            resolve();
          }, 10)
        })
      }

      //loop down from current in predictions, and if we have a prediction take it.
      for (let i = this.tickCount; i >= this.lastExecutedTick; i--) {
        if (this.tickPredictions[i]) {
          curPredictionTick = i;
          key = [(this.tickToEvent[i] || "NONE"), ...key]
          break;
        } else {
          key = [(this.tickToEvent[i] || "NONE"), ...key]
        }
      }

      key = key.join(',')

      this.tickResults[this.tickCount] = this.tickPredictions[curPredictionTick][key];

      // Send the result to the UI callback
      this.callback(this.tickResults[this.tickCount])

      this.tickCount += 1;
    }
  }

  async tick(lastResult, eventToSend) {
    var eventsToSend = [];
    if (eventToSend && eventToSend !== "NONE") {
      eventsToSend = [eventToSend]
    }
    let tickToSend = lastResult ? parseInt(lastResult.tickCount) + 1 : 0;
    const result = await fcl.send([
      fcl.script`${replaceImports(tickCode, this.gameEngineAddress)}`,
      fcl.args([
        fcl.arg(this.contractAddress, t.Address),
        fcl.arg(this.contractName, t.String),
        fcl.arg(this.levelName, t.String),
        fcl.arg(tickToSend.toString(), t.UInt64),
        fcl.arg(
          lastResult.objects.map((obj) => {
            return Object.entries(obj).map(([k,v]) => {
              return { key: k, value: v }
            })
          })
          ,
          t.Array(
            t.Dictionary({ key: t.String, value: t.String })
          )
        ),
        fcl.arg(eventsToSend, t.Array(t.String)),
        fcl.arg(
          Object.entries(lastResult.state).map(([k,v]) => {
            return { key: k, value: v }
          }),
          t.Dictionary({ key: t.String, value: t.String })
        ),
        fcl.arg(
          (this.predictionLength + 1).toString(),
          t.Int
        )
      ])
    ]).then(fcl.decode)
    
    this.lastBaseTick = parseInt(lastResult.tickCount);

    return result;
  }

  async sendPlayerEvent(event) {
    this.curEvent = event;
  }

  pause() {

  }
}

export default Game;
