import "GameEngine"
import "AsteroidsGame"

// This is the most basic transaction you can execute on Flow Network
transaction() {
  prepare(signer: AuthAccount) {
    let newGame <- GameEngine.createNewGame(levels: [
      AsteroidsGame.Level1(),
      AsteroidsGame.Level2()
    ])
    signer.save(<-newGame, to: /storage/MyGame)
    signer.link<&{GameEngine.GamePublic}>(/public/MyGame, target: /storage/MyGame)
  }
  execute {
    
  }
}
