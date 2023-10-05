import "GameEngine"
import "TraditionalTetrisPieces"
import "GameBoardUtils"

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
    pub var dropRate: UInt64
    pub var lastDropTick: UInt64
    
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
      self.dropRate = 0 // Measured in ticks - 0 means it doesn't drop automatically
      self.lastDropTick = UInt64(0)
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
          "relativePositions": GameBoardUtils.convertRelativePositionsToString(self.relativePositions),
          "shape": self.shape,
          "rotation": self.rotation!.toString(),
          "color": self.color,
          "dropRate": self.dropRate.toString(),
          "lastDropTick": self.lastDropTick.toString()
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
      self.dropRate = UInt64.fromString(map["dropRate"]!)!
      self.lastDropTick = UInt64.fromString(map["lastDropTick"]!)!
    }

    pub fun tick(
      tickCount: UInt64,
      events: [GameEngine.PlayerEvent],
      level: {GameEngine.Level},
      callbacks: {String: ((AnyStruct?): AnyStruct?)}
    ) {
      var prevTetrimone = self
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
          self.lastDropTick = tickCount
          break
        }
      }
      if (self.lastDropTick == 0) {
        self.lastDropTick = tickCount
      }
      if (self.dropRate > 0 && tickCount - self.lastDropTick >= self.dropRate) {
        self.referencePoint[0] = self.referencePoint[0]! + 1
        needsRedraw = true
        self.lastDropTick = tickCount
      }
      // Check for collisions. If we're redrawing that means theres a chance at a collision.
      if (needsRedraw) {
        let collisionMap: [[Int]] = level.gameboard.getCollisionMap(self)
        if (collisionMap.length > 0) {
          // Remove the piece from the gameboard and from the level entirely
          callbacks["remove"]!(prevTetrimone)
          // Lock the piece in place into the locked piece
          callbacks["expandLockedIn"]!(prevTetrimone)
          // spawn a new piece
          callbacks["spawn"]!(nil)
        } else {
          callbacks["redraw"]!({
            "prev": prevTetrimone,
            "new": self
          })
        }
      }
    }
  }

  pub struct LockedInTetrisPiece: GameEngine.GameObject {
    // Standard fields
    pub var id: UInt64
    pub var type: String
    pub var doesTick: Bool
    pub var relativePositions: [[Int]]
    pub var referencePoint: [Int]
    pub var rotation: Int?
    pub var color: String
    
    pub fun setColor(_ color: String) {
      self.color = color
    }
    pub fun setID(_ id: UInt64) {
      self.id = id
    }
    pub fun setRelativePositions(_ pos: [[Int]]) {
      self.relativePositions = pos
    }
    pub fun setReferencePoint(_ point: [Int]) {
      self.referencePoint = point
    }

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
          "relativePositions": GameBoardUtils.convertRelativePositionsToString(self.relativePositions),
          "color": self.color
      }
    }

    pub fun expand(_ object: {GameEngine.GameObject}) {
      var i = 0
      while (i < object.relativePositions.length) {
        var j = 0
        while (j < object.relativePositions[i].length) {
          let x = object.referencePoint[0]!
          let y = object.referencePoint[1]!
          let relativeX = x + i
          let relativeY = y + j
          if (object.relativePositions[i][j] == 1) {
            var column = self.relativePositions[relativeX]!
            column[relativeY] = 1
            self.relativePositions[relativeX] = column
          }
          j = j + 1
        }
        i = i + 1
      }
    }

    pub fun fromMap(_ map: {String: String}) {
      self.id = UInt64.fromString(map["id"]!)!
      self.type = map["type"]!
      self.doesTick = (map["doesTick"]!) == "true"
      let x = Int.fromString(map["x"]!)
      let y = Int.fromString(map["y"]!)
      self.referencePoint = [x!, y!]
      self.relativePositions = GameBoardUtils.convertStringToRelativePositions(map["relativePositions"]!)
      self.color = map["color"]!
    }

    pub fun tick(
      tickCount: UInt64,
      events: [GameEngine.PlayerEvent],
      level: {GameEngine.Level},
      callbacks: {String: ((AnyStruct?): AnyStruct?)}
    ) {
      // do nothing
    }

    init() {
      self.id = UInt64(999999999)
      self.type = "LockedInTetrisPiece"
      self.doesTick = false
      self.referencePoint = [0, 0]
      self.relativePositions = []
      self.rotation = 0
      self.color = "black"
    }
  }
}