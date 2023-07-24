import "GameEngine"
import "GameBoardUtils"

pub fun main(address: Address, levelIndex: Int, lastTick: UInt64, board: String, events: [String]): {String: AnyStruct} {
  let gameCap = getAccount(address).getCapability(/public/MyGame)
  if gameCap == nil {
    panic("Game not found")
  }
  let gamePublic = gameCap!.borrow<&{GameEngine.GamePublic}>()!

  let level = gamePublic.getLevel(levelIndex: levelIndex)
  let conversionMap = level.textToTypeMap()
  let typeToTextMap: {String: String} = GameBoardUtils.flipConversionMap(map: conversionMap)

  var parsedEvents: [GameEngine.PlayerEvent] = []
  for e in events {
    if (e == "left") {
      parsedEvents.append(
        GameEngine.PlayerEvent(type: "left")
      )
    }
    if (e == "right") {
      parsedEvents.append(
        GameEngine.PlayerEvent(type: "right")
      )
    }
  }

  let gameOutput = gamePublic.tickLevel(levelIndex: levelIndex, input: 
    GameEngine.GameTickInput(
      tickCount: lastTick,
      gameboard: GameBoardUtils.convertStringToGameboard(board: board, conversionMap: conversionMap),
      events: parsedEvents
    )
  )

  var res: {String: AnyStruct} = {}
  res["tickCount"] = gameOutput.tickCount
  res["boardString"] = GameBoardUtils.convertGameboardToString(board: gameOutput.gameboard, conversionMap: typeToTextMap)
  res["tickSpeed"] = level.extras["tickSpeed"]
  res["score"] = level.extras["score"]
  res["message"] = level.extras["message"]
  return res
}
