import "GameLevels"
import "GameEngine"
import "GameBoardUtils"
import "GamePieces"

pub contract AsteroidsGame: GameLevels {
  /*
  pub struct Level1: GameEngine.Level {
    pub let state: {String: String}
    pub let extras: {String: AnyStruct}
    
    pub fun textToTypeMap(): {String: GameEngine.GameObjectType} {
      let createAsteroid = (fun (): AnyStruct{GameEngine.GameObject} {
        return GamePieces.Asteroid()
      })
      let createPlayer = (fun (): AnyStruct{GameEngine.GameObject} {
        return GamePieces.SideScrollPlayer()
      })
      return {
        "A": GameEngine.GameObjectType(
          type: Type<GamePieces.Asteroid>(),
          createType: createAsteroid
        ),
        "P": GameEngine.GameObjectType(
          type: Type<GamePieces.SideScrollPlayer>(),
          createType: createPlayer
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
      let lastRow: [AnyStruct{GameEngine.GameObject}?] = board[height-1]!
      lastRow[(Int(unsafeRandom()) % (width-1))] = GamePieces.SideScrollPlayer()
      board[height-1] = lastRow

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

    init() {
      self.state = {}
      self.extras = {}
      self.extras["tickSpeed"] = 200
      self.extras["score"] = 0
      self.extras["message"] = ""
    }
  }

  pub struct Level2: GameEngine.Level {
    pub let state: {String: String}
    pub let extras: {String: AnyStruct}
    
    pub fun textToTypeMap(): {String: GameEngine.GameObjectType} {
      let createAsteroid = (fun (): AnyStruct{GameEngine.GameObject} {
        return GamePieces.Asteroid()
      })

      let createPlayer = (fun (): AnyStruct{GameEngine.GameObject} {
        return GamePieces.SideScrollPlayer()
      })

      return {
        "O": GameEngine.GameObjectType(
          type: Type<GamePieces.Asteroid>(),
          createType: createAsteroid
        ),
        "X": GameEngine.GameObjectType(
          type: Type<GamePieces.SideScrollPlayer>(),
          createType: createPlayer
        )
      }
    }

    pub fun getCallbacks(): {String: AnyStruct} {
      return {}
    }

    pub fun createInitialGameboard(numPlayers: Int): [[AnyStruct{GameEngine.GameObject}?]] {
      assert(numPlayers == 1, message: "Only 1 player allowed")
      let width = 30;
      let height = 20;
      let board: [[AnyStruct{GameEngine.GameObject}?]] =  GameBoardUtils.createBoard(width: width, height: height)
      let lastRow: [AnyStruct{GameEngine.GameObject}?] = board[height-1]!
      lastRow[(Int(unsafeRandom()) % (width-1))] = GamePieces.SideScrollPlayer()
      board[height-1] = lastRow

      return board
    }

    // Post tick runs after each item has been ticked already
    pub fun postTick(input: GameEngine.GameTickInput): [[AnyStruct{GameEngine.GameObject}?]] {
      let tickCount = input.tickCount
      let gameboard = input.gameboard
      
      let asteroid: GamePieces.Asteroid = GamePieces.Asteroid()
      let x = Int(unsafeRandom()) % gameboard[0]!.length

      if (tickCount % 2 == 0) {
        self.extras["score"] = (self.extras["score"] as! Int?)! + 1
        var firstRow = gameboard[0]!
        firstRow[x] = asteroid as! AnyStruct{GameEngine.GameObject}
        gameboard[0] = firstRow
      }
      return gameboard
    }

    init() {
      self.state = {}
      self.extras = {}
      self.extras["tickSpeed"] = 10
      self.extras["score"] = 0
      self.extras["message"] = ""
    }
  }
   

  pub fun getAvailableLevels(): [String] {
    return [
      "Level1",
      "Level2"
    ]
  }

  pub fun createLevel(name: String): AnyStruct? {
    switch name {
      case "Level1":
        return nil
    }
    return nil
  }*/

}
