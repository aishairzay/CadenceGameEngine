import "GameEngine"

pub contract GamePieces {
  
  pub struct SideScrollPlayer: GameEngine.GameObject {
    pub var doesTick: Bool
    pub var lastMoveTick: UInt64?

    pub fun tick(
      input: GameEngine.GameTickInput,
      callbacks: {String: AnyStruct}
    ): [[AnyStruct{GameEngine.GameObject}?]] {
      let position: [Int] = (callbacks["getPosition"] as! ((): [Int])?)!()
      let curRow = position[0]!
      let curCol = position[1]!

      var direction: String? = nil
      for e in input.events {
        if (e.type == "right") {
          direction = e.type
        }
        if (e.type == "left") {
          direction = e.type
        }
      }

      var newGameboard = input.gameboard
      var canMove = true
      if (self.lastMoveTick != nil && input.tickCount - self.lastMoveTick! < 1) {
        canMove = false
      }
      if (canMove && direction != nil) {
        var newPlayer = SideScrollPlayer()
        newPlayer.doesTick = false
        let myRow = newGameboard[curRow]!
        if (direction == "left" && curCol > 0) {
          myRow[curCol - 1] = newPlayer
          myRow[curCol] = nil
        }
        if (direction == "right" && curCol + 1 < myRow.length) {
          myRow[curCol + 1] = newPlayer
          myRow[curCol] = nil
        }
        newGameboard[curRow] = myRow
        self.lastMoveTick = input.tickCount
      }
      return newGameboard
    }

    init() {
      self.doesTick = true
      self.lastMoveTick = nil
    }
  }

  pub struct Asteroid: GameEngine.GameObject {
    pub var doesTick: Bool

    pub fun tick(
      input: GameEngine.GameTickInput,
      callbacks: {String: AnyStruct}
    ): [[AnyStruct{GameEngine.GameObject}?]] {
      let position: [Int] = (callbacks["getPosition"] as! ((): [Int])?)!()
      let curRow = position[0]
      let curCol = position[1]

      let curGameboard = input.gameboard
      let newRow = curRow + 1
      let newCol = curCol
      let newGameboard = curGameboard

      // Replace current asteroid row with nil
      var oldRow = newGameboard[curRow]!
      oldRow[curCol] = nil
      newGameboard[curRow] = oldRow

      // Add new asteroid row if we aren't past the height of the board
      if (newRow < newGameboard.length) {
        var movedRow = newGameboard[newRow]!
        let newAsteroid = Asteroid()
        newAsteroid.doesTick = false
        movedRow[newCol] = newAsteroid
        newGameboard[newRow] = movedRow
      }

      return newGameboard
    }

    init() {
      self.doesTick = true
    }
  }

  pub struct Consumable: GameEngine.GameObject {
    pub var doesTick: Bool
    
    pub fun tick(
      input: GameEngine.GameTickInput,
      callbacks: {String: AnyStruct}
    ): [[AnyStruct{GameEngine.GameObject}?]] {
      let position: [Int] = (callbacks["getPosition"] as! ((): [Int])?)!()
      let curRow = position[0]
      let curCol = position[1]

      return input.gameboard
    }

    init() {
      self.doesTick = true
    }
  }

  pub struct SnakeTail: GameEngine.GameObject {
    pub var doesTick: Bool
    
    pub fun tick(
      input: GameEngine.GameTickInput,
      callbacks: {String: AnyStruct}
    ): [[AnyStruct{GameEngine.GameObject}?]] {
      let position: [Int] = (callbacks["getPosition"] as! ((): [Int])?)!()
      let curRow = position[0]
      let curCol = position[1]

      return input.gameboard
    }

    init() {
      self.doesTick = true
    }
  }
}