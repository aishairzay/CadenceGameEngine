import React, { useEffect } from 'react';
import {
  createBrowserRouter,
  RouterProvider,
} from "react-router-dom";
import Home from './Home';
import About from './pages/About';
import Mod from './pages/Mod';
import Create from './pages/Create';
import GameSelection from './pages/GameSelection';
import Game from './pages/Game';
import Options from './pages/Options';
import bgImage from './assets/cyberpunk_bg.png';
import styled from 'styled-components';

const OuterContainer = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  width: 100vw;
  background-image: url(${bgImage});
  background-size: cover;
  background-repeat: no-repeat;
`;

const ContentContainer = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 80%;
  width: 70%;
  color: #00FF41;
  border: 3px solid #414345; // darken border color
  box-shadow: 0px 0px 30px #000000; // add shadow to give depth
  background-color: rgba(0, 0, 0, 0.5); // semi-transparent background
  backdrop-filter: blur(5px); // blur effect to background within container
`;

const router = createBrowserRouter([
  {
    path: "/",
    element: (
      <Home></Home>
    )
  },
  {
    path: "/arcade",
    element: (
      <GameSelection />
    )
  },
  {
    path: "/about",
    element: (
      <About />
    )
  },
  {
    path: "/game",
    element: (
      <div>
          game
      </div>
    )
  },
  {
    path: "/options",
    element: (
      <Options />
    )
  },
  {
    path: "/create",
    element: (
      <Create />
    )
  },
  {
    path: "/mod",
    element: (
      <Mod />
    )
  },
  {
    path: "/game/:network/:address/:contract/:level",
    element: (
      <Game />
    )
  }
])

export default function Arcade() {

  useEffect(() => {});

  return (
    <OuterContainer>
      <ContentContainer>
        <RouterProvider router={router} />
      </ContentContainer>
    </OuterContainer>
  );
}