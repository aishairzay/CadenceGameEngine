import "GameEngine"
import "GameBoardUtils"

pub fun main(address: Address, levelIndex: Int): {String: AnyStruct} {
  let gameCap = getAccount(address).getCapability(/public/MyGame)
  if gameCap == nil {
    panic("Game not found")
  }
  let gamePublic = gameCap!.borrow<&{GameEngine.GamePublic}>()!

  let level = gamePublic.getLevel(levelIndex: levelIndex)
  let conversionMap = level.textToTypeMap()
  let typeToTextMap: {String: String} = GameBoardUtils.flipConversionMap(map: conversionMap)
  
  let gameOutput = gamePublic.startLevel(levelIndex: levelIndex)

  var res: {String: AnyStruct} = {}
  res["tickCount"] = gameOutput.tickCount
  res["boardString"] = GameBoardUtils.convertGameboardToString(board: gameOutput.gameboard, conversionMap: typeToTextMap)
  res["tickSpeed"] = level.extras["tickSpeed"]
  res["score"] = level.extras["score"]
  res["message"] = level.extras["message"]
  return res
}
