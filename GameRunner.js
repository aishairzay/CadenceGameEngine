
const fcl = require('@onflow/fcl');
const t = require('@onflow/types');
const { startTransaction } = require('./FlowHelper');

const path = require('path');
const transactionsPath = path.join(__dirname, 'cadence', 'transactions', '/')
const scriptsPath = path.join(__dirname, 'cadence', 'scripts', '/')

var running = false;

const convertImports = async (str) => {
  str = str.replace("import \"GameEngine\"", "import GameEngine from 0x01cf0e2f2f715450")
  str = str.replace("import \"GameBoardUtils\"", "import GameBoardUtils from 0x01cf0e2f2f715450")
  str = str.replace("import \"AsteroidsGame\"", "import AsteroidsGame from 0x01cf0e2f2f715450")
  return str
}

const convertCadenceToJs = async () => {
  const resultingJs = await require('cadence-to-json')({
    transactions: [transactionsPath],
    scripts: [scriptsPath],
    config: require('./flow.json')
  })
  return resultingJs
}

const sleep = async (ms) => {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function run(flowAddress, levelIndex, callbacks) {
  const cadence = await convertCadenceToJs()

  fcl
    .config()
    .put('accessNode.api', 'http://localhost:8888')  // Set up your access node
  
  try {
    // Run the CreateGameResource transaction on the CLI using exec to make sure there is a game created before we continue
    await startTransaction(
      await convertImports(cadence.transactions.EmptyTx),
      (arg, t) => []
    )

    // Run the CreateGameResource transaction on the CLI using exec to make sure there is a game created before we continue
    await startTransaction(
      await convertImports(cadence.transactions.CreateGameResource),
      (arg, t) => []
    )
  } catch(e) {
    // do nothing
  }

  const startGameResult = await fcl.send([
    fcl.script`${await convertImports(cadence.scripts.StartGame)}`,
    fcl.args([
        fcl.arg(flowAddress, t.Address),
        fcl.arg(levelIndex, t.Int)
    ])
  ]).then(fcl.decode)

  let gameboard = startGameResult.boardString;
  console.log("Initial gameboard is: ");
  console.log(gameboard.replaceAll('|', '\n'));
  let tickCount = startGameResult.tickCount;
  let tickSpeed = startGameResult.tickSpeed;
  let score = startGameResult.score;

  console.log("Starting tick loop.")
  while (true && running) {
    try {
      const txResult = await startTransaction(
        cadence.transactions.EmptyTx,
        (arg, t) => []
      )
    } catch (e) {
      // do nothing
    }

    const events = callbacks.popEvents()

    const tickResult = await fcl.send([
      fcl.script`${await convertImports(cadence.scripts.TickGame)}`,
      fcl.args([
          fcl.arg(flowAddress, t.Address),
          fcl.arg(levelIndex, t.Int),
          fcl.arg(tickCount, t.UInt64),
          fcl.arg(gameboard, t.String),
          fcl.arg(events, t.Array(t.String))
      ])
    ]).then(fcl.decode)
    gameboard = tickResult.boardString;
    tickCount = tickResult.tickCount;

    callbacks.updateGameboard(gameboard.replaceAll('|', '\n'))

    // clear the console
    console.clear()

    console.log(`TICK #${tickCount}`)
    console.log(`SCORE: ${score}`)
    console.log(gameboard.replaceAll('|', '\n'));

    await sleep(tickSpeed);
  }
  if (!running) {
    console.log("Game stopped.")
  }
}

const { Server } = require("socket.io");
const io = new Server({
  cors: {
    origin: "http://localhost:3000",
  }
});

io.on('connection', (socket) => {
  let events = []
  console.log('a user connected');
  // when receiving start message, run the game
  socket.on('start', (data) => {
    running = true
    const address = data.address
    const levelIndex = data.levelIndex

    run(
      address,
      levelIndex,
      {
        updateGameboard: (gameboard) => {
          socket.emit('updateGameboard', gameboard);
        },
        popEvents: () => {
          // copy events to new object and return it
          const eventsCopy = events
          events = []
          return eventsCopy
        }
      }
    )
  })

  socket.on('input', (msg) => {
    console.log('input message received', msg);
    if (msg === 'left') {
      events = ['left']
    } else if (msg === 'right') {
      events = ['right']
    }  else if (msg === 'up') { 
      events = ['up']
    } else if (msg === 'down') {
      events = ['down']
    }
  })

  socket.on('stop', (msg) => {
    console.log('stop message received');
    running = false;
  })

  socket.on('disconnect', () => {
    console.log('user disconnected');
    running = false
  })
});

io.listen(3001)
console.log("Socket.io listening on port 3001")
