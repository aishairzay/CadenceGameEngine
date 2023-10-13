export const startCode = 
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
    "extras": level.extras
  }
}
`

export const tickCode = `

import "GameLevels"
import "GameEngine"
import "GameBoardUtils"

pub fun runTicks(
  _ contractAddress: Address,
  _ contractName: String,
  _ levelName: String,
  _ input: GameEngine.GameTickInput,
  _ depth: Int,
  _ maxDepth: Int,
  _ eventChain: String,
  _ tickResults: {String: AnyStruct}): {String: AnyStruct} {

  if (depth == maxDepth) {
    return tickResults
  }

  let level: {GameEngine.Level} = GameEngine.tickLevel(
    contractAddress: contractAddress,
    contractName: contractName,
    levelName: levelName,
    input: input
  )
  
  var newTickResults = tickResults
  let objects = GameEngine.convertGameObjectsToStrMaps(level.objects)
  newTickResults[eventChain] = {
    "tickCount": input.tickCount,
    "objects": objects,
    "state": level.state,
    "extras": level.extras
  }

  var possibleEvents: [String] = level.extras["possibleEventInputs"]! as! [String]
  possibleEvents.append("NONE")
  for e in possibleEvents {
    var newEventChain = eventChain
    if (eventChain.length > 0) {
      newEventChain = eventChain.concat(",").concat(e)
    } else {
      newEventChain = eventChain.concat(e)
    }
    let newInput = GameEngine.GameTickInput(
      tickCount: input.tickCount + 1,
      objects: level.objects.values,
      events: [GameEngine.PlayerEvent(type: e)],
      state: level.state
    )
    newTickResults = runTicks(
      contractAddress,
      contractName,
      levelName,
      newInput,
      depth + 1,
      maxDepth,
      newEventChain,
      newTickResults
    )
  }
  return newTickResults
  
}

pub fun main(contractAddress: Address, contractName: String, levelName: String, lastTick: UInt64, gameObjects: [{String: String}], events: [String], state: {String: String}, predictionCount: Int): AnyStruct {
  let roLevel: {GameEngine.Level} = GameEngine.getLevel(contractAddress: contractAddress, contractName: contractName, levelName: levelName)
  let gameObjects: [{GameEngine.GameObject}?] = roLevel.parseGameObjectsFromMaps(gameObjects)

  // todo convert events to GameEngine.PlayerEvent
  var playerEvents: [GameEngine.PlayerEvent] = []
  var eventToSend = "NONE"
  for event in events {
    playerEvents.append(GameEngine.PlayerEvent(event))
    eventToSend = event
  }

  let tickResults: {String: AnyStruct} = {}

  let finalResults: {String: AnyStruct} = runTicks(
    contractAddress,
    contractName,
    levelName,
    GameEngine.GameTickInput(
      tickCount: lastTick,
      objects: gameObjects,
      events: playerEvents,
      state: state
    ),
    0,
    predictionCount,
    eventToSend,
    tickResults
  )

  return finalResults
}

`