import "GameLevels"
import "GameEngine"
import "TraditionalTetrisPieces"

pub contract Tetris: GameLevels {
  
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
    // Real pieces can be made with `create`
    // This is our replacement for now having a static constructor
    // since cadence does not support static constructors yet, and
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

    pub fun tick(input: GameEngine.GameTickInput, gameboard: [[{GameEngine.GameObject}?]]): GameEngine.GameTickOutput {
      return GameEngine.GameTickOutput(
        tickCount: input.tickCount,
        objects: input.objects,
        gameboard: gameboard,
        state: input.state
      )
    }
  }

  pub struct StandardLevel: GameEngine.Level {
    // State is data meant to be carried between ticks
    // as both input and output
    pub let state: {String: String}
    pub let boardWidth: Int
    pub let boardHeight: Int
    pub let viewWidth: Int
    pub let viewHeight: Int
    pub let tickRate: Int

    // Extras is data that is not meant to be carried between ticks
    // and is only used as output from a tick to the client
    pub let extras: {String: AnyStruct}

    pub fun createInitialGameObjects(): [{GameEngine.GameObject}?] {
      let tetrisPiece = TetrisPiece()
      
      tetrisPiece.fromMap(
        {
          "id": "1",
          "type": "TetrisPiece",
          "doesTick": "true",
          "x": "4",
          "y": "4",
          "shape": "L",
          "rotation": "0",
          "color": "red"
        }
      )
      return [
        tetrisPiece
      ]
    }

    pub fun parseGameObjectsFromMaps(_ map: [{String: String}]): [{GameEngine.GameObject}?] {
      let objects: [{GameEngine.GameObject}?] = []
      for objectMap in map {
        let object = TetrisPiece()
        object.fromMap(objectMap)
        objects.append(object)
      }
      return objects
    }
  
    pub fun createGameboardFromObjects(_ gameObjects: [{GameEngine.GameObject}?]): [[{GameEngine.GameObject}?]] {
      return []
    }

    // Default implementation of tick is to tick on all contained
    // game objects that have doesTick set to true
    pub fun tick(input: GameEngine.GameTickInput, gameboard: [[{GameEngine.GameObject}?]]): GameEngine.GameTickOutput {
      return GameEngine.GameTickOutput(
        tickCount: input.tickCount,
        objects: input.objects,
        gameboard: gameboard,
        state: input.state
      )
    }

    // Default implementation of postTick is to do nothing
    pub fun postTick(input: GameEngine.GameTickInput, gameboard: [[{GameEngine.GameObject}?]]): GameEngine.GameTickOutput {
      return GameEngine.GameTickOutput(
        tickCount: input.tickCount,
        objects: input.objects,
        gameboard: gameboard,
        state: input.state
      )
    }

    init() {
      self.boardWidth = 10
      self.boardHeight = 24
      self.viewWidth = 10
      self.viewHeight = 24
      self.tickRate = 1 // ideal ticks per second from the client
      self.state = {
        "score": "0"
      }
      self.extras = {}
    }
  }

  pub fun createLevel(_ name: String): AnyStruct? {
    return StandardLevel()
  }
  
  pub fun getAvailableLevels(): [String] {
    return [
      "StandardLevel"
    ]
  }

}