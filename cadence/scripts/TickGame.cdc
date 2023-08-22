import "GameLevels"
import "GameEngine"
import "GameBoardUtils"

pub fun main(contractAddress: Address, contractName: String, levelName: String, lastTick: UInt64, objects: {String: AnyStruct}, events: [String], state: {String: String}): AnyStruct {
  let level: {GameEngine.GameLevel} = GameEngine.getLevel(contractAddress: contractAddress, contractName: contractName, levelName: levelName)
  let gameObjects: [GameEngine.GameObject] = level.parseGameObjectsFromMap(objects)

  let gameInput: GameEngine.GameTickInput = GameEngine.GameTickInput(
    tickCount: lastTick,
    objects: gameObjects,
    events: events,
    state: state
  )
  return GameEngine.tickLevel(
    contractAddress: contractAddress,
    contractName: contractName,
    levelName: levelName,
    input: gameInput
  )
}
