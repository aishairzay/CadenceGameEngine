import React, { useState, useEffect } from 'react';
import { socket } from './Socket';

export default function App() {
  const [isConnected, setIsConnected] = useState(socket.connected);
  const [address, setAddress] = useState('0xf8d6e0586b0a20c7');
  const [levelIndex, setLevelIndex] = useState('0');
  const [gameboard, setGameboard] = useState('');

  useEffect(() => {
    document.addEventListener("keydown", (e) => {
      if (e.code === 'ArrowUp') {
        socket.emit('input', 'up')
      } else if (e.code === 'ArrowDown') {
        socket.emit('input', 'down')
      } else if (e.code === 'ArrowLeft') {
        socket.emit('input', 'left')
      } else if (e.code === 'ArrowRight') {
        socket.emit('input', 'right')
      }
    });

    function onConnect() {
      setIsConnected(true);
      console.log('connected')
    }

    function onDisconnect() {
      setIsConnected(false);
    }

    function updateGameboard(value) {
      setGameboard(value);
    }

    socket.on('connect', onConnect);
    socket.on('updateGameboard', updateGameboard);
    socket.on('disconnect', onDisconnect);

    return () => {
      socket.off('connect', onConnect);
      socket.off('disconnect', onDisconnect);
    };
  }, []);

  return (
    <div className="App">
      <h1>Connect to a Flow Game</h1>
      ---Game Address:
      <input
        type="text"
        placeholder="Enter the Flow address of the game"
        value={address}
        onChange={event => setAddress(event.target.value)}
      />
      ---Level:
      <input
        type="text"
        placeholder="Enter the level index"
        value={levelIndex}
        onChange={event => setLevelIndex(event.target.value)}
      />

      <button
        onClick={() => {
          // emit socket with the inputted address and level index
          socket.emit('start', { address, levelIndex });
        }}
      >
        Start Game
      </button>
      <p style={{
        fontFamily: 'monospace',
        whiteSpace: 'pre-wrap'
      }}>
        {gameboard}
      </p>
    </div>
  );
}