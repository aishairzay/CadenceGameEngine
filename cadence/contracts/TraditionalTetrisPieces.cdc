pub contract TraditionalTetrisPieces {

  // This map is a map of piece names to a map of rotations to a 4x4 matrix of 1s and 0s
  access(contract) let pieceMap: {String: {Int: [[Int]]}}

  pub fun getRandomPiece(): String {
    let rand = unsafeRandom()
    let length = self.pieceMap.keys.length
    let randPiece: Int = Int((rand % UInt64(length)))
    let pieceName = self.pieceMap.keys[randPiece]!
    return pieceName
  }

  pub fun getPiece(_ name: String, _ rotation: Int): [[Int]] {
    return self.pieceMap[name]![rotation]!
  }

  pub fun getPieces(): {String: {Int: [[Int]]}} {
    return self.pieceMap
  }

  init() {
    self.pieceMap = {
      "S": {
        0: [
          [1,1,0,0],
          [0,1,1,0],
          [0,0,0,0],
          [0,0,0,0]
        ],
        1: [
          [0,1,0,0],
          [1,1,0,0],
          [1,0,0,0],
          [0,0,0,0]
        ],
        2: [
          [0,1,1,0],
          [1,1,0,0],
          [0,0,0,0],
          [0,0,0,0]
        ],
        3: [
          [1,0,0,0],
          [1,1,0,0],
          [0,1,0,0],
          [0,0,0,0]
        ]
      },
      "L": {
        0: [
          [0,0,1,0],
          [1,1,1,0],
          [0,0,0,0],
          [0,0,0,0]
        ],
        1: [
          [1,1,0,0],
          [0,1,0,0],
          [0,1,0,0],
          [0,0,0,0]
        ],
        2: [
          [1,1,1,0],
          [1,0,0,0],
          [0,0,0,0],
          [0,0,0,0]
        ],
        3: [
          [1,0,0,0],
          [1,0,0,0],
          [1,1,0,0],
          [0,0,0,0]
        ]
      }
    }
  }
}