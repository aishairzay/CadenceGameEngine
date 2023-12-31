import { useState, useEffect } from 'react';
import Game from '../../flow/Game';

var game = null;

const createBoard = (boardWidth, boardHeight, colorMap) => {
  const board = [];
  for (let row = 0; row < boardHeight; row++) {
    const currentRow = [];
    for (let col = 0; col < boardWidth; col++) {
      const color = colorMap && colorMap[row] && colorMap[row][col] ? colorMap[row][col].color : '#5A5A5A';
      currentRow.push(
        <div
          key={`${row}-${col}`}
          style={{
            width: '20px',
            height: '20px',
            border: '1px solid black',
            backgroundColor: color
          }}
        ></div>
      );
    }
    board.push(
      <div 
        key={row} 
        style={{ 
          display: 'flex',
          flexDirection: 'row' 
        }}
      >
        {currentRow}
      </div>
    );
  }
  return board;
};

export default function GamePlayer({ network, address, contract, level }) {
  const [tickResult, setTickResult] = useState(null);
  const [gameStarted, setGameStarted] = useState(false);

  const startButtonStyle = {
    padding: '10px 20px',
    fontSize: '1em',
    fontWeight: 'bold',
    borderRadius: '5px',
    backgroundColor: '#007bff',
    color: 'white',
    cursor: 'pointer',
    border: 'none',
    boxShadow: '0px 3px 5px rgba(0,0,0,0.2)',
    marginBottom: '20px',
    marginTop: '20px'
  };

  useEffect(() => {
    if (!address || !contract || !level || !gameStarted) {
      return;
    }

    game = new Game(
      network,
      address,
      contract,
      level,
      (tickResult) => {
        console.log('Game tick result', tickResult);
        setTickResult(tickResult);
      }
    );

    game.start();
    
    document.addEventListener("keyup", (event) => {
      game.sendPlayerEvent(event.key);
    });

    return () => {
      // Cleanup
      document.removeEventListener("keyup", game.sendPlayerEvent);
    };

  }, [address, contract, level, gameStarted]);

  const startGame = () => {
    setGameStarted(true);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
      <div style={{ display: 'flex', justifyContent: 'center' }}>
        <div style={{
          width: 'fit-content',
          marginBottom: '20px'
        }}
        >
          {!gameStarted ? <button style={startButtonStyle} onClick={startGame}>Start Game</button> : null}
          {tickResult && (
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              {createBoard(parseInt(tickResult.extras.boardWidth), parseInt(tickResult.extras.boardHeight), tickResult.gameboard)}
            </div>
          )}
        </div>
        <div style={{ marginLeft: '20px' }}>
          {tickResult && tickResult.extras.description && (
            <p>{tickResult.extras.description}</p>
          )}
          {tickResult && tickResult.state.score && (
            <p>Score: {tickResult.state.score}</p>
          )}
        </div>
      </div>
    </div>
  );
}
