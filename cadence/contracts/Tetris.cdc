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

    pub fun createNewTetrisPiece(): TetrisObjects.TetrisPiece {
      let tetrisPiece = TetrisObjects.TetrisPiece()
      if (self.state["lastShape"] == nil) {
        self.state["lastShape"] = "L"
      }
      let shape = TraditionalTetrisPieces.getNextShape(self.state["lastShape"]!)
      // Make the active piece slightly transparent.
      let color = TraditionalTetrisPieces.getColorForShape(shape).concat("99")
      self.state["lastShape"] = shape

      tetrisPiece.fromMap(
        {
          "id": "1",
          "type": "TetrisPiece",
          "doesTick": "true",
          "x": "0",
          "y": "4",
          "shape": shape,
          "rotation": "0",
          "color": color,
          "dropRate": "5",
          "lastDropTick": "0"
        }
      )
      return tetrisPiece
    }

    pub fun createInitialGameObjects(): [{GameEngine.GameObject}?] {
      let tetrisPiece = self.createNewTetrisPiece()
      let lockedInTetrisPiece = TetrisObjects.LockedInTetrisPiece()
      var fullRow: [Int] = []
      var i = 0
      var emptyRow: [Int] = []
      while (i < self.boardWidth) {
        emptyRow.append(0)
        fullRow.append(1)
        i = i + 1
      }
      var j = 0
      var lockedInitialPositions: [Int] = []
      while (j < self.boardWidth) {
        lockedInitialPositions.append(1)
        j = j + 1
      }

      lockedInTetrisPiece.setRelativePositions([lockedInitialPositions])
      lockedInTetrisPiece.setReferencePoint([self.boardHeight-1, 0])

      return [
        tetrisPiece,
        lockedInTetrisPiece
      ]
    }

    pub fun parseGameObjectsFromMaps(_ map: [{String: String}]): [{GameEngine.GameObject}?] {
      let objects: [{GameEngine.GameObject}?] = []
      for objectMap in map {
        var object: {GameEngine.GameObject}? = nil
        if (objectMap["type"] == "TetrisPiece") {
          object = TetrisObjects.TetrisPiece()
        }
        if (objectMap["type"] == "LockedInTetrisPiece") {
          object = TetrisObjects.LockedInTetrisPiece()
        }
        object!.fromMap(objectMap)
        objects.append(object!)
      }
      return objects
    }

    pub fun tick(tickCount: UInt64, events: [GameEngine.PlayerEvent]) {
      var keys = self.objects.keys
      for key in keys {
        if (self.objects[key] == nil) {
          continue
        }
        let object = self.objects[key]!
        if (self.objects[key]!.doesTick) {
          // When passed as a parameter, level is readonly because the param copies the level.
          // For any actions that might be required that need to affect the actual level,
          // we provide the callbacks object.
          let redraw = fun (_ object: AnyStruct?): AnyStruct? {
            let map = object! as! {String: {GameEngine.GameObject}}
            let prevObject = map["prev"]!
            let gameObject = map["new"]!
            self.gameboard.remove(prevObject)
            self.gameboard.add(gameObject)
            return nil
          }
          let remove = fun (_ object: AnyStruct?): AnyStruct? {
            let gameObject = object! as! {GameEngine.GameObject}
            self.gameboard.remove(gameObject)
            self.objects.remove(key: gameObject.id)
            return nil
          }
          let spawn = fun (_ object: AnyStruct?): AnyStruct? {
            let newTetrisPiece = self.createNewTetrisPiece()
            self.objects[newTetrisPiece.id] = newTetrisPiece
            self.gameboard.add(newTetrisPiece)
            return nil
          }
          let expandLockedIn = fun (_ object: AnyStruct?): AnyStruct? {
            let gameObject = object! as! TetrisObjects.TetrisPiece

            var color = gameObject.color.slice(from:0, upTo:7) // Remove the opacity

            var newRows: {Int: Bool} = {}
            // loop through all of the relative positions of the tetris piece
            // and create a new individual locked in piece for each one
            // with the same reference point and color as the tetris piece
            var i = 0
            while (i < gameObject.relativePositions.length) {
              var j = 0
              while (j < gameObject.relativePositions[i].length) {
                if (gameObject.relativePositions[i][j] == 1) {
                  let newLockedInPiece = TetrisObjects.LockedInTetrisPiece()
                  newLockedInPiece.setID(UInt64.fromString(self.state["lastID"]!)!)
                  self.state["lastID"] = (UInt64.fromString(self.state["lastID"]!)! + 1).toString()
                  newLockedInPiece.setRelativePositions([[1]])
                  newLockedInPiece.setReferencePoint([gameObject.referencePoint[0] + i, gameObject.referencePoint[1] + j])
                  newRows[gameObject.referencePoint[0] + i] = true
                  newLockedInPiece.setColor(color)
                  self.gameboard.add(newLockedInPiece)
                  self.objects[newLockedInPiece.id] = newLockedInPiece
                }
                j = j + 1
              }
              i = i + 1
            }

            // check if any of the `newRows` are full
            // if they are, remove them and shift all of the locked in pieces above them down
            // also increment the score state
            var rowsToRemove: [Int] = []
            for row in newRows.keys {
              if (self.gameboard.board[row]!.keys.length == self.boardWidth) {
                self.state["score"] = (UInt64.fromString(self.state["score"]!)! + 1).toString()
                let values = self.gameboard.board[row]!.values
                for lockedInPiece in values {
                  self.objects.remove(key: lockedInPiece!.id)
                  self.gameboard.remove(lockedInPiece!)
                }

                // Shift all game objects above the row down
                var i = row
                while (i > 0) {
                  if (self.gameboard.board[i] == nil) {
                    i = i - 1
                    continue
                  }
                  for j in self.gameboard.board[i]!.keys {
                    let obj: TetrisObjects.LockedInTetrisPiece?? = self.gameboard.board[i]![j]! as? TetrisObjects.LockedInTetrisPiece?
                    if (obj == nil || obj! == nil) {
                      continue
                    }
                    let prev = obj!!
                    self.objects[prev.id]!.setReferencePoint([i+1, j])
                    let params: {String: {GameEngine.GameObject}} = {
                      "prev": prev,
                      "new": self.objects[prev.id]!
                    }
                    redraw(params)
                  }
                  i = i - 1
                }
              }
            }
            
            
            return nil
          }
          let callbacks: {String: ((AnyStruct?): AnyStruct?)} = {
            "redraw": redraw,
            "remove": remove,
            "spawn": spawn,
            "expandLockedIn": expandLockedIn
          }
          self.objects[key]!.tick(
            tickCount: tickCount,
            events: events,
            level: self,
            callbacks: callbacks
          )
        }
      }
    }

    pub fun postTick(tickCount: UInt64, events: [GameEngine.PlayerEvent]) {
      // do nothing
    }

    init() {
      self.boardWidth = 10
      self.boardHeight = 20
      self.tickRate = 10 // ideal ticks per second from the client
      self.state = {
        "score": "0",
        "lastID": "2"
      }
      self.extras = {
        "boardWidth": self.boardWidth,
        "boardHeight": self.boardHeight,
        "description": "A traditional tetris level w/ some bugs.",
        "possibleEventInputs": ["ArrowUp", "ArrowRight", "ArrowDown", "ArrowLeft"]
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