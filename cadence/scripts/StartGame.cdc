import "GameLevels"
import "GameEngine"
import "GameBoardUtils"

pub fun main(contractAddress: Address, contractName: String, levelName: String): AnyStruct {
  return GameEngine.startLevel(
    contractAddress: contractAddress,
    contractName: contractName,
    levelName: levelName
  )
}
