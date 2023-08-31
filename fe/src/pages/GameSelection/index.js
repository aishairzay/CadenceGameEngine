import React, { useEffect, useState } from 'react';
import TetrisIcon from '../../assets/tetris-icon.png';

export default function GameSelection() {
  const [showCustomLevel, setShowCustomLevel] = useState(false);
  const [customData, setCustomData] = useState({
    network: 'testnet',
    address: '0xdcafeba3ddf31cee',
    gameName: 'Tetris',
    levelName: 'StandardLevel'
  });

  useEffect(() => {});

  const gameContainerStyle = {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    margin: '20px',
    padding: '20px',
    border: '1px solid grey',
    borderRadius: '10px',
    width: '200px',
    cursor: 'pointer'
  };

  const gameImageStyle = {
    width: '100px',
    height: '100px',
    marginBottom: '10px'
  };

  const gameTitleStyle = {
    fontSize: '1.2em',
    fontWeight: 'bold',
    color: 'white'
  };

  const buttonStyle = {
    marginTop: '15px',
    padding: '10px 20px',
    fontSize: '1em',
    borderRadius: '5px',
    backgroundColor: '#007bff',
    color: 'white',
    cursor: 'pointer',
    border: 'none'
  };

  const redirectToGame = () => {
    window.location.href = 'game/mainnet/0x7963a4eb8583241f/Tetris/StandardLevel';
  };

  const handleCustomGame = () => {
    const { network, address, gameName, levelName } = customData;
    window.location.href = `game/${network}/${address}/${gameName}/${levelName}`;
  };

  const handleInputChange = (e, field) => {
    setCustomData({
      ...customData,
      [field]: e.target.value
    });
  };

  return (
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', flexDirection: 'column' }}>
      <h1>Choose a Game</h1>
      <div style={gameContainerStyle} onClick={redirectToGame}>
        <img src={TetrisIcon} alt="Tetris Icon" style={gameImageStyle} />
        <div style={gameTitleStyle}>Tetris</div>
      </div>

      <button style={buttonStyle} onClick={() => setShowCustomLevel(!showCustomLevel)}>Go to Custom Level</button>

      {showCustomLevel && (
        <div style={{ margin: '20px' }}>
          <input
            type="text"
            placeholder="Network"
            value={customData.network}
            onChange={(e) => handleInputChange(e, 'network')}
          />
          <input
            type="text"
            placeholder="Address"
            value={customData.address}
            onChange={(e) => handleInputChange(e, 'address')}
          />
          <input
            type="text"
            placeholder="Game Name"
            value={customData.gameName}
            onChange={(e) => handleInputChange(e, 'gameName')}
          />
          <input
            type="text"
            placeholder="Level Name"
            value={customData.levelName}
            onChange={(e) => handleInputChange(e, 'levelName')}
          />
          <button onClick={handleCustomGame}>Go</button>
        </div>
      )}
    </div>
  );
}
