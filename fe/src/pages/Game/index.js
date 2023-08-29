import { useEffect } from 'react';
import { useParams } from 'react-router-dom';
import GamePlayer from './GamePlayer';


export default function Game() {
  useEffect(() => {});
  let { address, contract, level } = useParams();

  return (
    <>
      <h1>Playing {contract} - {level} hosted by {address}</h1>
      <GamePlayer
        address={address}
        contract={contract}
        level={level}
      />
    </>
  );
}
