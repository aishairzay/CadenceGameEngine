import "GameEngine"
import "TraditionalTetrisPieces"

pub contract TetrisObjects {
  // GameObject for a TetrisPiece
  pub struct TetrisPiece: GameEngine.GameObject {
    // Standard fields
    pub var id: UInt64
    pub var type: String
    pub var doesTick: Bool
    pub var relativePositions: [[Int]]
    pub var referencePoint: [Int]
    pub var shape: String
    pub var rotation: Int?
    
    // Tetris-specific fields
    pub var color: String

    // Our init creates an unusable empty tetris piece.
    // Real pieces can be made with `fromMap`
    // This is our replacement for not having a static constructor
    // since cadence does not support static constructors, and
    // we need to be able to create pieces for the map.
    init() {
      self.id = UInt64(0)
      self.type = "TetrisPiece"
      self.doesTick = true
      self.referencePoint = [0, 0]
      self.shape = "L"
      self.relativePositions = []
      self.rotation = 0
      self.color = "white"
    }

    // This gives the FE a way to represent the object on the board
    // as well s giving it a way to pass the state back into the SC
    pub fun toMap(): {String: String} {
      var doesTick = "false"
      if (self.doesTick) {
        doesTick = "true"
      }
      return {
          "id": self.id.toString(),
          "type": self.type,
          "doesTick": doesTick,
          "x": self.referencePoint[0]!.toString(),
          "y": self.referencePoint[1]!.toString(),
          "shape": self.shape,
          "rotation": self.rotation!.toString(),
          "color": self.color
      }
    }

    // This gives the SC a way to create an object from the FE's representation
    pub fun fromMap(_ map: {String: String}) {
      self.id = UInt64.fromString(map["id"]!)!
      self.type = map["type"]!
      self.doesTick = (map["doesTick"]!) == "true"
      let x = Int.fromString(map["x"]!)
      let y = Int.fromString(map["y"]!)
      self.referencePoint = [x!, y!]
      self.shape = map["shape"]!
      self.rotation = Int.fromString(map["rotation"]!)
      self.relativePositions = TraditionalTetrisPieces.getPiece(self.shape, self.rotation!)
      self.color = map["color"]!
    }

    pub fun tick(
      tickCount: UInt64,
      events: [GameEngine.PlayerEvent],
      level: {GameEngine.Level}
    ): Bool {

      let handleCollision = fun (_ prev: {GameEngine.GameObject}?, _ cur: {GameEngine.GameObject},_ collisionMap: [[Int]]): {GameEngine.GameObject}? {
        // do nothing
        return nil
      }
      var needsRedraw = false
      for e in events {
        if (e.type == "ArrowUp") {
          self.rotation = (self.rotation! + 1) % 4
          self.relativePositions = TraditionalTetrisPieces.getPiece(self.shape, self.rotation!)
          needsRedraw = true
          break
        }
        if (e.type == "ArrowRight") {
          let rightMostX = self.referencePoint[1]! + self.relativePositions[0].length
          if (rightMostX > level.boardWidth - 1) {
            break
          }
          self.referencePoint[1] = self.referencePoint[1]! + 1
          needsRedraw = true
          break
        }
        if (e.type == "ArrowLeft") {
          let newX = self.referencePoint[1]! - 1
          if (newX < 0) {
            break
          }
          self.referencePoint[1] = newX
          needsRedraw = true
          break
        }
        if (e.type == "ArrowDown") {
          self.referencePoint[0] = self.referencePoint[0]! + 1
          needsRedraw = true
          break
        }
      }
      return needsRedraw
    }
  }
}