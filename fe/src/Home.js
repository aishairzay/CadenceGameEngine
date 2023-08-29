import React from 'react';
import MenuButton from './MenuButton';
import styled from 'styled-components';

const HomeContainer = styled.div`
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;

  /* Apply offset for all children */
  & > * {
    position: relative;
    left: -150px; /* Initialize left offset */
  }

  /* Apply offset for each child */
  & > *:nth-child(2) {
    left: -75px; /* Offset second child */
  }

  & > *:nth-child(3) {
    left: 0px; /* Offset third child */
  }

  & > *:nth-child(4) {
    left: 75px; /* Offset fourth child */
  }

  & > *:nth-child(5) {
    left: 150px; /* Offset fourth child */
  }
`;

function Home() {
  return (
      <HomeContainer>
          <MenuButton buttonText="Play 1P-Game" path="/arcade" />
          <MenuButton buttonText="Mod a Game" path="/mod" />
          <MenuButton buttonText="Create a Game" path="/create" />
          <MenuButton buttonText="Options" path="/options" />
          <MenuButton buttonText="About" path="/about" />
      </HomeContainer>
  );
}

export default Home;
