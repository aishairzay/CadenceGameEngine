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