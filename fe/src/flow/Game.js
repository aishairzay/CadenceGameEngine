import * as fcl from "@onflow/fcl";
const t = require('@onflow/types');

const startCode = 
`
import "GameLevels"
import "GameEngine"
import "GameBoardUtils"

pub fun main(contractAddress: Address, contractName: String, levelName: String): AnyStruct {
  let level: {GameEngine.Level} = GameEngine.startLevel(
    contractAddress: contractAddress,
    contractName: contractName,
    levelName: levelName
  )
  let objects = GameEngine.convertGameObjectsToStrMaps(level.objects)
  return {
    "tickCount": 0,
    "objects": objects,
    "state": level.state,
    "gameboard": level.gameboard.board,
    "extras": level.extras
  }
}
`

const tickCode = 
`
import "GameLevels"
import "GameEngine"
import "GameBoardUtils"

pub fun main(contractAddress: Address, contractName: String, levelName: String, lastTick: UInt64, gameObjects: [{String: String}], events: [String], state: {String: String}): AnyStruct {
  let roLevel: {GameEngine.Level} = GameEngine.getLevel(contractAddress: contractAddress, contractName: contractName, levelName: levelName)
  let gameObjects: [{GameEngine.GameObject}?] = roLevel.parseGameObjectsFromMaps(gameObjects)

  // todo convert events to GameEngine.PlayerEvent
  var playerEvents: [GameEngine.PlayerEvent] = []
  for event in events {
    playerEvents.append(GameEngine.PlayerEvent(event))
  }

  let gameInput: GameEngine.GameTickInput = GameEngine.GameTickInput(
    tickCount: lastTick,
    objects: gameObjects,
    events: playerEvents,
    state: state
  )
  let level: {GameEngine.Level} = GameEngine.tickLevel(
    contractAddress: contractAddress,
    contractName: contractName,
    levelName: levelName,
    input: gameInput
  )

  let objects = GameEngine.convertGameObjectsToStrMaps(level.objects)

  return {
    "tickCount": lastTick + 1,
    "objects": objects,
    "state": level.state,
    "gameboard": level.gameboard.board,
    "extras": level.extras
  }
}

`

const GAME_ADDRESS = "0x01cf0e2f2f715450";
const replaceImports = (code) => {
  // replace lines that look like `import "GameLevels"` with "import GameLevels from GAME_ADDRESS"
  return code.replace(/import\s+"([^"]+)"/g, (match, p1) => {
    return `import ${p1} from ${GAME_ADDRESS}`;
  })
};

class Game {
  constructor(contractAddress, contractName, levelName, tickCallback) {
    this.contractAddress = contractAddress;
    this.contractName = contractName;
    this.levelName = levelName;
    this.callback = tickCallback;
    this.curEvents = [];
    fcl.config().put("accessNode.api", "http://localhost:8888");
  }

  async start() {
    let lastResult = await fcl.send([
      fcl.script`${replaceImports(startCode)}`,
      fcl.args([
        fcl.arg(this.contractAddress, t.Address),
        fcl.arg(this.contractName, t.String),
        fcl.arg(this.levelName, t.String)
      ])
    ]).then(fcl.decode)
    this.callback(lastResult);

    setInterval(async () => {
      lastResult = await this.tick(lastResult);
      this.callback(lastResult);
    }, 100);

  }

  async tick(lastResult) {
    const eventsToSend = this.curEvents;
    this.curEvents = [];
    const result = await fcl.send([
      fcl.script`${replaceImports(tickCode)}`,
      fcl.args([
        fcl.arg(this.contractAddress, t.Address),
        fcl.arg(this.contractName, t.String),
        fcl.arg(this.levelName, t.String),
        fcl.arg(lastResult.tickCount, t.UInt64),
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
        )
      ])
    ]).then(fcl.decode)

    return result;
  }

  async sendPlayerEvent(event) {
    this.curEvents.push(event);
  }

  pause() {

  }
}

export default Game;
