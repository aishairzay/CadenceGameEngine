import "GameLevels"
import "GameEngine"
import "TraditionalTetrisPieces"
import "TetrisObjects"

pub contract Tetris: GameLevels {

  pub struct StandardLevel: GameEngine.Level {
    pub var gameboard: GameEngine.GameBoard
    pub var objects: { UInt64: {GameEngine.GameObject} }

    pub var state: {String: String}

    pub let tickRate: UInt64

    pub let boardWidth: Int
    pub let boardHeight: Int

    pub let extras: {String: AnyStruct}

    pub fun createInitialGameObjects(): [{GameEngine.GameObject}?] {
      let tetrisPiece = TetrisObjects.TetrisPiece()
      
      tetrisPiece.fromMap(
        {
          "id": "1",
          "type": "TetrisPiece",
          "doesTick": "true",
          "x": "0",
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
        let object = TetrisObjects.TetrisPiece()
        object.fromMap(objectMap)
        objects.append(object)
      }
      return objects
    }

    pub fun tick(tickCount: UInt64, events: [GameEngine.PlayerEvent]) {
      var keys = self.objects.keys
      for key in keys {
        let object = self.objects[key]!
        if (self.objects[key]!.doesTick) {
          let shouldRedraw = self.objects[key]!.tick(tickCount: tickCount, events: events, level: self)
          if (shouldRedraw) {
            self.gameboard.remove(object)
            self.gameboard.add(self.objects[key]!)
          }
        }
      }

    }

    pub fun postTick(tickCount: UInt64, events: [GameEngine.PlayerEvent]) {
      // do nothing
    }

    init() {
      self.boardWidth = 10
      self.boardHeight = 25
      self.tickRate = 10 // ideal ticks per second from the client
      self.state = {
        "score": "0"
      }
      self.extras = {
        "boardWidth": self.boardWidth,
        "boardHeight": self.boardHeight
      }
      self.objects = {}
      self.gameboard = GameEngine.GameBoard(
        width: self.boardWidth,
        height: self.boardHeight
      )
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