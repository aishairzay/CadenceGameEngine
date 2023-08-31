import { useEffect } from 'react';
import { useParams } from 'react-router-dom';
import GamePlayer from './GamePlayer';


export default function Game() {
  useEffect(() => {});
  let { network, address, contract, level } = useParams();

  return (
    <>
      <h1>Playing {contract} - {level}</h1>
      <h3>Hosted by {address} on {network}</h3>
      <GamePlayer
        network={network}
        address={address}
        contract={contract}
        level={level}
      />
    </>
  );
}
