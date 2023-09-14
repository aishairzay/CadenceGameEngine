import "GameEngine"

pub contract PacmanObjects {

  pub struct Player: GameEngine.GameObject {
    // Standard fields
    pub var id: UInt64
    pub var type: String
    pub var doesTick: Bool
    pub var relativePositions: [[Int]]
    pub var referencePoint: [Int]
    pub var color: String
    
    // Pacman-specific fields
    pub var direction: String
    pub var canEatGhosts: Bool

    init() {
      self.id = UInt64(0)
      self.type = "Player"
      self.doesTick = true
      self.referencePoint = [0, 0]
      self.relativePositions = []
      self.color = "yellow"
      self.direction = "right"
      self.canEatGhosts = false
    }

    pub fun toMap(): {String: String} {
      return {
        "id": self.id.toString(),
        "type": self.type,
        "doesTick": self.doesTick == true ? "true" : "false",
        "x": self.referencePoint[0].toString(),
        "y": self.referencePoint[1].toString(),
        "color": self.color,
        "direction": self.direction,
        "canEatGhosts": self.canEatGhosts == true ? "true" : "false"
      }
    }

    pub fun fromMap(_ map: {String: String}) {
      self.id = UInt64.fromString(map["id"]!)!
      self.type = map["type"]!
      self.doesTick = map["doesTick"] == "true"
      self.referencePoint = [Int.fromString(map["x"]!)!, Int.fromString(map["y"]!)!]
      self.color = map["color"]!
      self.direction = map["direction"]!
      self.canEatGhosts = map["canEatGhosts"] == "true"
    }

    pub fun tick(
      tickCount: UInt64,
      events: [GameEngine.PlayerEvent],
      level: {GameEngine.Level},
      callbacks: {String: ((AnyStruct?): AnyStruct?)}
    ) {
      // Assume one of the callbacks is for moving the player
      let moveCallback = callbacks["move"]! as? (([Int]) -> [Int])

      for event in events {
        if event.type == "keyboard" {
          if event.value == "up" {
            self.direction = "up"
          } else if event.value == "down" {
            self.direction = "down"
          } else if event.value == "left" {
            self.direction = "left"
          } else if event.value == "right" {
            self.direction = "right"
          }
        }
      }

      if self.direction == "up" {
        self.referencePoint = moveCallback!([0, -1])
      } else if self.direction == "down" {
        self.referencePoint = moveCallback!([0, 1])
      } else if self.direction == "left" {
        self.referencePoint = moveCallback!([-1, 0])
      } else if self.direction == "right" {
        self.referencePoint = moveCallback!([1, 0])
      }

      // Check for collision with Ghost
      let checkCollisionCallback = callbacks["checkCollision"]! as? ((String) -> [UInt64])
      let collidingObjects = checkCollisionCallback!("Ghost")
      if collidingObjects.count > 0 {
        // Game Over logic
      }
    }
  }

}