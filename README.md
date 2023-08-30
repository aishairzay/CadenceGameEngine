## Cadence Game Engine
Welcome to the Cadence Game Engine repository! This project represents a unique approach towards game engine design, with its functionality mastered in cadence and no reliance on transactions for game execution. This technique fosters rapid game progress through re-usable and composable code that can be deployed directly on-chain.

### Goals
The primary objective of this repository is to demonstrate the ability to run a game wherein the user interface is decoupled from the game mechanics and assets, all of which are managed on-chain. In this current phase, the emphasis is not on the verifiability of the game's execution or replayability, but rather on the 'fun' aspects and the reusability of game components (or GameObjects) to spawn new games.

This approach aims to inspire the community with the potential of on-chain gaming. Although on-chain verifiability is not the primary focus at this stage, the architecture is designed with future compatibility in mind, suggesting that such features can be seamlessly integrated later.

### Example
Provided in this repo is an example tetris game. 

### Workflow
![Amit's Opinionated Single-Player Game Engine](https://github.com/aishairzay/CadenceGameEngine/assets/1332984/150df54b-6f6b-47bc-a2a1-44ed35415e31)

This repo expands on the above by allowing a runner of the game to broadcast the game through socket.io to a client (and in the future to many clients) to enable a hosted multiplayer experience.
