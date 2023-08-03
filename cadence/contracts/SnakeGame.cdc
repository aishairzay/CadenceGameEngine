import "GameEngine"
import "GameBoardUtils"
import "GamePieces"

pub contract SnakeGame {
  pub struct Level1: GameEngine.Level {
    pub let state: {String: String}
    pub let extras: {String: AnyStruct}
    
    pub fun textToTypeMap(): {String: GameEngine.GameObjectType} {
      let createConsumable = (fun (): AnyStruct{GameEngine.GameObject} {
        return GamePieces.Consumable()
      })
      let createSnakeTail = (fun (): AnyStruct{GameEngine.GameObject} {
        return GamePieces.SnakeTail()
      })
      return {
        "X": GameEngine.GameObjectType(
          type: Type<GamePieces.Consumable>(),
          createType: createConsumable
        ),
        "S": GameEngine.GameObjectType(
          type: Type<GamePieces.SnakeTail>(),
          createType: createSnakeTail
        )
      }
    }

    pub fun getCallbacks(): {String: AnyStruct} {
      return {}
    }

    pub fun createInitialGameboard(numPlayers: Int): [[AnyStruct{GameEngine.GameObject}?]] {
      assert(numPlayers == 1, message: "Only 1 player allowed")
      let width = 20;
      let height = 20;
      let board: [[AnyStruct{GameEngine.GameObject}?]] =  GameBoardUtils.createBoard(width: width, height: height)

      return board
    }

    // Post tick runs after each item has been ticked already
    pub fun postTick(input: GameEngine.GameTickInput): [[AnyStruct{GameEngine.GameObject}?]] {
      let tickCount = input.tickCount
      let gameboard = input.gameboard
      
      let asteroid: GamePieces.Asteroid = GamePieces.Asteroid()
      let x = Int(unsafeRandom()) % gameboard[0]!.length

      if (tickCount % 15 == 0) {
        self.extras["score"] = (self.extras["score"] as! Int?)! + 1
        var firstRow = gameboard[0]!
        firstRow[x] = asteroid as! AnyStruct{GameEngine.GameObject}
        gameboard[0] = firstRow
      }
      return gameboard
    }

    access(self) fun convertCoordinateToInt(x: Int, y: Int): Int {
      return x + (y * 1000)
    }

    access(self) fun convertIntToCoordinate(i: Int): [Int] {
      return [Int(i % 1000), Int(i / 1000)]
    }

    init() {
      self.state = {}
      self.state["direction"] = "right"
      self.state["path"] = ""

      self.extras = {}
      self.extras["tickSpeed"] = 200
      self.extras["score"] = 0
      self.extras["message"] = ""
    }
  }
}