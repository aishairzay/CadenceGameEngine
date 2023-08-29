import { useEffect } from 'react';

export default function GameSelection() {
  useEffect(() => {});

  return (
    <>
    <h1>Choose a Game</h1>
      <a onClick={() => {
        window.location.href = '/game/0x01cf0e2f2f715450/Tetris/StandardLevel';
      }}>Tetris</a>
    </>
  );
}