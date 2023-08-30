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

export default function GamePlayer({ address, contract, level }) {
  const [tickResult, setTickResult] = useState(null);
  useEffect(() => {
    if (!address || !contract || !level) {
      return;
    }
    // start the game
    game = new Game(
      address,
      contract,
      level,
      (tickResult) => {
        console.log('Game tick result', tickResult);
        setTickResult(tickResult)
      }
    );
    game.start();
    
    document.addEventListener("keyup", (event) => {
      game.sendPlayerEvent(event.key)
    });
  }, [address, contract, level]);
  
  if (!tickResult || !tickResult.gameboard) {
    return null
  }
  

  const gameboard = tickResult.gameboard
  const boardWidth = parseInt(tickResult.extras.boardWidth)
  const boardHeight = parseInt(tickResult.extras.boardHeight)
  var board = []
  for (let i = 0; i < boardWidth; i++) {
    board.push([])
    for (let j = 0; j < boardHeight; j++) {
      board[i].push(null)
    }
  }
  
  return (
    <div style={{
      width: '30%',
      height: '100%',
      marginBottom: '20px'
    }}
    >
      {
        tickResult && (
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {createBoard(boardWidth, boardHeight, gameboard)}
          </div>
        )
      }
    </div>
  );
}
