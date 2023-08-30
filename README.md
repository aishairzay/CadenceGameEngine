## Cadence Game Engine
Welcome to the Cadence Game Engine repository! This project represents a unique approach towards game engine design, with its functionality mastered in cadence and no reliance on transactions for game execution. This technique fosters rapid game progress through re-usable and composable code that can be deployed directly on-chain.

### Goals
The primary objective of this repository is to demonstrate the ability to run a game wherein the user interface is decoupled from the game mechanics and assets, all of which are managed on-chain. In this current phase, the emphasis is not on the verifiability of the game's execution or replayability, but rather on the 'fun' aspects and the reusability of game components (or GameObjects) to spawn new games.

This approach aims to inspire the community with the potential of on-chain gaming. Although on-chain verifiability is not the primary focus at this stage, the architecture is designed with future compatibility in mind, suggesting that such features can be seamlessly integrated later.

### Example
Provided in this repo is an example tetris game mastered in the `Tetris` Smart Contract (SC). This SC implements the `GameEngine.GameLevels` and has a single `StandardLevel` class within it which implements a `GameEngine.GameLevel`. A GameLevel is made up of `GameEngine.GameObject`s, 2 of which are implemented in the `TetrisObjects` contract.

To run the example locally, clone this repo to your local, and run the emulator with `flow emulator` + `flow dev`. And then in another terminal, navigate to the `fe` folder, and run `npm start` to run the front-end locally.

### Workflow
![Amit's Opinionated Single-Player Game Engine (1)](https://github.com/aishairzay/CadenceGameEngine/assets/1332984/08f4bad3-f10c-4bda-a308-bb54491b4781)
