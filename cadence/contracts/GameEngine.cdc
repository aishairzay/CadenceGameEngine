pub contract GameEngine {

  pub struct interface GameObject {
    pub var doesTick: Bool

    pub fun tick(
      input: GameTickInput,
      callbacks: {String: AnyStruct}
    ): [[AnyStruct{GameObject}?]]
  }

  pub struct GameObjectType {
    pub let type: Type
    pub let createType: ((): AnyStruct{GameObject})

    init(type: Type, createType: ((): AnyStruct{GameObject})) {
      self.type = type
      self.createType = createType
    }
  }

  pub struct PlayerEvent {
    pub let type: String

    init(type: String) {
      self.type = type
    }
  }

  pub struct GameTickInput {
    pub let tickCount: UInt64
    pub var gameboard: [[AnyStruct{GameObject}?]]
    pub let events: [PlayerEvent]
    pub let state: {String: String}

    init(tickCount: UInt64, gameboard: [[AnyStruct{GameObject}?]], events: [PlayerEvent], state: {String: String}) {
      self.tickCount = tickCount
      self.gameboard = gameboard
      self.events = events
      self.state = state
    }
  }

  pub struct GameTickOutput {
    pub let tickCount: UInt64
    pub var gameboard: [[AnyStruct{GameObject}?]]

    init(tickCount: UInt64, gameboard: [[AnyStruct{GameObject}?]]) {
      self.tickCount = tickCount
      self.gameboard = gameboard
    }
  }

  pub struct interface Level {
    pub let state: {String: String}
    pub let extras: {String: AnyStruct}
  
    pub fun createInitialGameboard(numPlayers: Int): [[AnyStruct{GameEngine.GameObject}?]]
    pub fun getCallbacks(): {String: AnyStruct}
    pub fun textToTypeMap(): {String: GameObjectType} {
      return {}
    }

    // Default implementation of tick is to tick on all contained
    // game objects that have doesTick set to true
    pub fun tick(input: GameTickInput): [[AnyStruct{GameObject}?]] {
      var gameboard = input.gameboard
      let tickCount = input.tickCount
      let events = input.events
      var i = 0
      var callbacks = self.getCallbacks()

      while (i < gameboard.length) {
        var j = 0
        while (j < gameboard[i]!.length) {
          let t = gameboard[i]![j]
          if (t != nil && t!.doesTick) {

            callbacks["getPosition"] = (fun (): [Int] {
              return [i, j]
            })
            gameboard = t!.tick(
              input: GameEngine.GameTickInput(
                tickCount: input.tickCount,
                gameboard: gameboard,
                events: input.events,
                state: input.state
              ),
              callbacks: callbacks
            )
          }
          j = j + 1
        }
        i = i + 1
      }

      return gameboard
    }

    pub fun postTick(input: GameTickInput): [[AnyStruct{GameObject}?]]
  }

  pub resource interface GamePublic {
    pub fun getLevel(levelIndex: Int): AnyStruct{Level}
    pub fun startLevel(levelIndex: Int): GameTickOutput
    pub fun tickLevel(levelIndex: Int, input: GameTickInput): GameTickOutput
  }

  pub resource Game: GamePublic {
    pub let levels: [AnyStruct{Level}]

    pub fun getLevel(levelIndex: Int): AnyStruct{Level} {
      return self.levels[levelIndex]!
    }

    pub fun startLevel(levelIndex: Int): GameTickOutput {
      let board: [[AnyStruct{GameEngine.GameObject}?]] = self.levels[levelIndex].createInitialGameboard(numPlayers: 1)
      return GameTickOutput(
        tickCount: 0,
        gameboard: board
      )
    }

    pub fun tickLevel(levelIndex: Int, input: GameTickInput): GameTickOutput {
      var gameboard = self.levels[levelIndex].tick(input: input)
      gameboard = self.levels[levelIndex].postTick(input: GameTickInput(
        tickCount: input.tickCount,
        gameboard: gameboard,
        events: input.events,
        state: input.state
      ))
      return GameTickOutput(
        tickCount: input.tickCount + 1,
        gameboard: gameboard
      )
    }

    init(levels: [AnyStruct{Level}]) {
      self.levels = levels
    }
  }

  pub fun createNewGame(levels: [AnyStruct{Level}]): @Game {
    return <-create Game(levels: levels)
  }

}

