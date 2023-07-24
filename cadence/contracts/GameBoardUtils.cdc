import "GameEngine"
import "StringUtils"

pub contract GameBoardUtils {

  pub fun flipConversionMap(map: {String: GameEngine.GameObjectType}): {String: String} {
    var conversionMap: {String: String} = {}
    let keys = map.keys
    for key in keys {
      let value = map[key]!.type.identifier
      conversionMap[value] = key
    }
    return conversionMap
  }

  pub fun createBoard(width: Int, height: Int): [[AnyStruct{GameEngine.GameObject}?]] {
    var board: [[AnyStruct{GameEngine.GameObject}?]] = []
    var i = 0
    var j = 0

    while (i < height) {
      let row: [AnyStruct{GameEngine.GameObject}?] = []
      j = 0
      while (j < width) {
        row.append(nil)
        j = j + 1
      }
      board.append(row)
      i = i + 1
    }
    return board;
  }

  pub fun convertGameboardToString(board: [[AnyStruct{GameEngine.GameObject}?]], conversionMap: {String: String}): String {
    var boardStr: String = ""
    var i = 0
    var j = 0
    // loop through the passed in board, and convert each element to a string
    // and append it to the result string

    while (i < board.length) {
      var row = ""
      j = 0
      while (j < board[i]!.length) {
        if (board[i]![j] == nil) {
          row = StringUtils.join([row, "_"], "")
          j = j + 1
          continue
        }
        let o = board[i]![j]!
        let identifier = o.getType().identifier
        let letter = conversionMap[identifier]!
        row = StringUtils.join([row, letter], "")
        j = j + 1
      }
      if (boardStr.length == 0) {
        boardStr = row
      } else {
        boardStr = StringUtils.join([boardStr, row], "|")
      }
      i = i + 1
    }
    return boardStr
  }

  pub fun convertStringToGameboard(board: String, conversionMap: {String: GameEngine.GameObjectType}): [[AnyStruct{GameEngine.GameObject}?]] {
    var boardArray: [[AnyStruct{GameEngine.GameObject}?]] = []
    var i = 0
    var j = 0
    let splitBoard: [String] = StringUtils.split(board, "|")
    while (i < splitBoard.length){ 
      j = 0
      var row: [AnyStruct{GameEngine.GameObject}?] = []
      while (j < splitBoard[i]!.length) {
        if (splitBoard[i]![j] == "_") {
          row.append(nil)
          j = j + 1
          continue
        }
        let letter = splitBoard[i]![j]!
        let gameObjectType = conversionMap[(letter.toString())]!
        let gameObject: AnyStruct{GameEngine.GameObject} = gameObjectType.createType()
        row.append(gameObject)
        j = j + 1
      }
      i = i + 1
      boardArray.append(row)
    }
    return boardArray
  }
}
