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