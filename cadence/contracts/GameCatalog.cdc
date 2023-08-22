pub contract GameCatalog {
  pub struct Game {
    pub let levelType: Type
    pub let gameEngineType: Type
    pub let name: String
    pub let description: String
    pub let image: String

    init(levelType: Type, gameEngineType: Type, name: String, description: String, image: String) {
      self.levelType = levelType
      self.gameEngineType = gameEngineType
      self.name = ""
      self.description = ""
      self.image = ""
    }
  }

  pub let games: [Game]

  pub fun addGame(game: Game) {
    self.games.append(game)
  }

  init() {
    self.games = []
  }
}