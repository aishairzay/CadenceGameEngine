import "GameLevels"

pub contract GameEngine {

  pub struct interface GameObject {
    pub var id: UInt64
    pub var type: String
    pub var doesTick: Bool
    pub var referencePoint: [Int]
    pub var relativePositions: [[Int]]

    pub fun toMap(): {String: String}
    pub fun fromMap(_ map: {String: String})

    pub fun setReferencePoint(_ newReferencePoint: [Int]) {
      self.referencePoint = newReferencePoint
    }

    pub fun tick(
      tickCount: UInt64,
      events: [PlayerEvent],
      level: {Level},
      callbacks: {
        String: ((AnyStruct?): AnyStruct?)
      }
    )
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
    pub var objects: [{String: String}]
    pub var gameboard: {Int: {Int: {GameObject}?}}
    pub let state: {String: String}
  
    init(tickCount: UInt64, objects: [{String: String}], gameboard:{Int: {Int: AnyStruct{GameEngine.GameObject}?}}, state: {String: String}) {
      self.tickCount = tickCount
      self.objects = objects
      self.gameboard = gameboard
      self.state = state
    }
  }

  // ------------------------------------------
  // Begin GameBoard struct
  // ------------------------------------------
  pub struct GameBoard {
    pub var board: {Int: {Int: {GameObject}?}}
    pub var width: Int
    pub var height: Int

    access(self) fun updateBoard(_ gameObject: {GameObject}, _ isRemoval: Bool) {
      let referencePoint: [Int] = gameObject.referencePoint
      var x = 0
      var xLen = gameObject.relativePositions.length

      while x < xLen {
        var y = 0
        var yLen = gameObject.relativePositions[x]!.length
        while y < yLen {
          if (gameObject.relativePositions[x]![y]! == 0) {
            y = y + 1
          } else {
            let curX = referencePoint[0]! + x
            let curY = referencePoint[1]! + y
            
            if (self.board[curX] == nil) {
              self.board[curX] = {}
            }
            var column = self.board[curX]!
            if (isRemoval) {
              column[curY] = nil
            } else {
              column[curY] = gameObject
            }
            self.board[curX] = column
            y = y + 1
          }
        }
        x = x + 1
      }
    }

    // Add the given gameobject to the gameboard
    pub fun add(_ gameObject: {GameObject}) {
      self.updateBoard(gameObject, false)
    }

    // Remove this object from the gameboard
    pub fun remove(_ gameObject: {GameObject}?) {
      if (gameObject != nil) {
        self.updateBoard(gameObject!, true)
      }
    }

    pub fun getCollisionMap(_ gameObject: {GameObject}): [[Int]] {
      var collisionMap: [[Int]] = []
      var x = 0
      let xLen = gameObject.relativePositions.length
      while (x < xLen) {
        var y = 0
        let yLen = gameObject.relativePositions[x]!.length
        while (y < yLen) {
          if (gameObject.relativePositions[x]![y]! == 0) {
            y = y + 1
          } else {
            let curX = gameObject.referencePoint[0]! + x
            let curY = gameObject.referencePoint[1]! + y
            if (self.board[curX] != nil &&
                self.board[curX]![curY] != nil &&
                self.board[curX]![curY]!?.id != gameObject.id
            ) {
              collisionMap.append([curX, curY])
            }
            y = y + 1
          }
        }
        x = x + 1
      }
      return collisionMap
    }

    init(width: Int, height: Int) {
      self.board = {}
      self.width = 0
      self.height = 0
    }
  }

  // ------------------------------------------
  // Begin Level interface
  // ------------------------------------------
  pub struct interface Level {
    pub var gameboard: GameBoard
    pub var objects: { UInt64: {GameObject} }

    // State is data meant to be carried between ticks
    // as both input and output
    pub var state: {String: String}

    // The tick rate is the number of ticks per second
    pub let tickRate: UInt64

    // Size of the 2d board for this level
    // and what is visible of the board on the screen
    pub let boardWidth: Int
    pub let boardHeight: Int

    // Extras is data that is not meant to be carried between ticks
    // and is only used as output from a tick to the client
    pub let extras: {String: AnyStruct}

    pub fun createInitialGameObjects(): [{GameObject}?]
    pub fun parseGameObjectsFromMaps(_ map: [{String: String}]): [{GameObject}?]
    pub fun storeGameObjects(_ objects: [{GameObject}?]) {
      for object in objects {
        if (object != nil) {
          self.objects[object!.id] = object!
          self.gameboard.add(object!)
        }
      }
    }

    pub fun setState(_ state: {String: String}) {
      self.state = state
    }

    // Default implementation of tick is to tick on all contained
    // game objects that have doesTick set to true
    pub fun tick(tickCount: UInt64, events: [PlayerEvent])

    // Default implementation of postTick is to do nothing
    pub fun postTick(tickCount: UInt64, events: [PlayerEvent])
  }

  // ------------------------------------------
  // End Level interface
  // ------------------------------------------

  // ------------------------------------------
  //  Public game engine functions
  // ------------------------------------------

  pub fun convertGameObjectsToStrMaps(_ gameObjects: { UInt64: {GameEngine.GameObject} }): [{String: String}] {
    var maps: [{String: String}] = []
    var keys = gameObjects.keys
    for key in gameObjects.keys {
      var obj = gameObjects[key]!
      maps.append(obj.toMap())
    }
    return maps
  }

  pub fun startLevel(contractAddress: Address, contractName: String, levelName: String): {Level} {
    let gameLevels: &GameLevels = getAccount(contractAddress).contracts.borrow<&GameLevels>(name: contractName)
      ?? panic("Could not borrow a reference to the GameLevels contract")
    let level: {Level} = gameLevels.createLevel(levelName)! as! {Level}

    // Create the initial objects for the game. This will create a new list of game objects
    let objects: [AnyStruct{GameObject}?] = level.createInitialGameObjects()
    level.storeGameObjects(objects)
    return level
  }

  pub fun getLevel(contractAddress: Address, contractName: String, levelName: String): {Level} {
    let gameLevels: &GameLevels = getAccount(contractAddress).contracts.borrow<&GameLevels>(name: contractName)
      ?? panic("Could not borrow a reference to the GameLevels contract")
    let level: {Level} = gameLevels.createLevel(levelName)! as! {Level}
    return level
  }

  pub fun tickLevel(contractAddress: Address, contractName: String, levelName: String, input: GameTickInput): {Level} {
    let gameLevels: &GameLevels = getAccount(contractAddress).contracts.borrow<&GameLevels>(name: contractName)
      ?? panic("Could not borrow a reference to the GameLevels contract")
    let level: {Level} = gameLevels.createLevel(levelName)! as! {Level}

    // Setup the level with initial state from the input
    level.storeGameObjects(input.objects)
    level.setState(input.state)

    // Tick the level
    level.tick(tickCount: input.tickCount, events: input.events)
    level.postTick(tickCount: input.tickCount, events: input.events)

    return level
  }

}

