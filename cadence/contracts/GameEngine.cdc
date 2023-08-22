import "GameLevels"

pub contract GameEngine {

  pub struct interface GameObject {
    pub var id: UInt64
    pub var type: String
    pub var doesTick: Bool
    pub var referencePoint: [Int]
    pub var relativePositions: [[Int]]
    pub var rotation: Int?

    pub fun toMap(): {String: AnyStruct}
    pub fun fromMap(_ map: {String: AnyStruct})

    pub fun tick(
      input: GameTickInput,
      gameboard: [[{GameObject}?]]
    ): GameTickOutput
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
    pub var objects: [{GameObject}?]
    pub let events: [PlayerEvent]
    pub let state: {String: String}

    init(tickCount: UInt64, objects: [{GameObject}?], events: [PlayerEvent], state: {String: String}) {
      self.tickCount = tickCount
      self.objects = objects
      self.events = events
      self.state = state
    }
  }

  pub struct GameTickOutput {
    pub let tickCount: UInt64
    pub var objects: [{GameObject}?]
    pub var gameboard: [[{GameObject}?]]
    pub let state: {String: String}

    init(tickCount: UInt64, objects: [{GameObject}?], gameboard:[[{GameObject}?]], state: {String: String}) {
      self.tickCount = tickCount
      self.objects = objects
      self.gameboard = gameboard
      self.state = state
    }
  }

  pub struct interface Level {
    // State is data meant to be carried between ticks
    // as both input and output
    pub let state: {String: String}

    // Extras is data that is not meant to be carried between ticks
    // and is only used as output from a tick to the client
    pub let extras: {String: AnyStruct}

    pub fun createInitialGameObjects(): [{GameObject}?]
    pub fun createGameboardFromObjects(_ gameObjects: [{GameObject}?]): [[{GameObject}?]]
    pub fun parseGameObjectsFromMap(_ map: {String: AnyStruct}): [{GameObject}?]

    // Default implementation of tick is to tick on all contained
    // game objects that have doesTick set to true
    pub fun tick(input: GameTickInput, gameboard: [[{GameObject}?]]): GameTickOutput {
      return GameTickOutput(
        tickCount: input.tickCount,
        objects: input.objects,
        gameboard: gameboard,
        state: input.state
      )
    }

    // Default implementation of postTick is to do nothing
    pub fun postTick(input: GameTickInput, gameboard: [[{GameObject}?]]): GameTickOutput {
      return GameTickOutput(
        tickCount: input.tickCount,
        objects: input.objects,
        gameboard: gameboard,
        state: input.state
      )
    }
  }

  pub fun startLevel(contractAddress: Address, contractName: String, levelName: String): GameTickOutput {
    let gameLevels: &GameLevels = getAccount(contractAddress).contracts.borrow<&GameLevels>(name: contractName)
      ?? panic("Could not borrow a reference to the GameLevels contract")
    let level: {Level} = gameLevels.createLevel(levelName)! as! {Level}

    // Create the initial objects for the game. This will create a new list of game objects
    let objects: [AnyStruct{GameObject}?] = level.createInitialGameObjects()

    let gameboard: [[{GameObject}?]] = level.createGameboardFromObjects(objects)

    return GameTickOutput(
      tickCount: 0,
      objects: objects,
      gameboard: gameboard,
      state: level.state
    )
  }

  pub fun getLevel(contractAddress: Address, contractName: String, levelName: String): {Level} {
    let gameLevels: &GameLevels = getAccount(contractAddress).contracts.borrow<&GameLevels>(name: contractName)
      ?? panic("Could not borrow a reference to the GameLevels contract")
    let level: {Level} = gameLevels.createLevel(levelName) as! {Level}
    return level
  }

  pub fun tickLevel(contractAddress: Address, contractName: String, levelName: String, input: GameTickInput): GameTickOutput {
    let gameLevels: &GameLevels = getAccount(contractAddress).contracts.borrow<&GameLevels>(name: contractName)
      ?? panic("Could not borrow a reference to the GameLevels contract")
    let level: {Level} = gameLevels.createLevel(levelName) as! {Level}
    let gameboard: [[{GameObject}?]] = level.createGameboardFromObjects(input.objects)

    var gameOutput: GameTickOutput = level.tick(input: input, gameboard: gameboard)
    gameOutput = level.postTick(
      input: GameTickInput(
        tickCount: gameOutput.tickCount,
        objects: gameOutput.objects,
        events: input.events,
        state: gameOutput.state
      ),
      gameboard: gameOutput.gameboard
    )
    return GameTickOutput(
      tickCount: input.tickCount + 1,
      objects: gameOutput.objects,
      gameboard: gameOutput.gameboard,
      state: gameOutput.state
    )
  }

}

