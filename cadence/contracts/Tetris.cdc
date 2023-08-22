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
    pub var referencePoint: [Int]
    pub var relativePositions: [[Int]]
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
      self.relativePositions = [[0, 0]]
      self.rotation = nil
      self.color = "white"
    }
    
    // This gives the FE a way to represent the object on the board
    // as well s giving it a way to pass the state back into the SC
    pub fun toMap(): {String: AnyStruct} {
        return {
            "id": self.id,
            "type": self.type,
            "doesTick": self.doesTick,
            "referencePoint": self.referencePoint,
            "relativePositions": self.relativePositions,
            "rotation": self.rotation,
            "color": self.color
        }
    }
    
    // This gives the SC a way to create an object from the FE's representation
    pub fun fromMap(_ map: {String: AnyStruct}) {
        self.id = UInt64(map["id"]! as! Int)
        self.type = map["type"]! as! String
        self.doesTick = map["doesTick"]! as! Bool
        self.referencePoint = map["referencePoint"]! as! [Int]
        self.relativePositions = map["relativePositions"]! as! [[Int]]
        self.rotation = map["rotation"]! as! Int
        self.color = map["color"]! as! String
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
          "id": 1,
          "type": "TetrisPiece",
          "doesTick": true,
          "referencePoint": [4, 4],
          "relativePositions": [[0, 0]],
          "rotation": 0,
          "color": "red"
        }
      )
      return [
        tetrisPiece
      ]
    }

    pub fun parseGameObjectsFromMap(_ map: {String: AnyStruct}): [{GameEngine.GameObject}?] {
      return []
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
      self.state = {}
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