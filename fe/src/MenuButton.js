import React from 'react';
import { useNavigate } from 'react-router-dom';
import styled from 'styled-components';

// Style MenuButton component
const StyledMenuButton = styled.button`
  width: 300px; /* Set a fixed width */
  text-align: center; /* Center the text */
  box-sizing: border-box;
  font-size: 2em;
  color: #00FF41; /* Purple text color */
  text-shadow: 0 0 5px #00FF41, 0 0 10px #00FF41;
  border: none;
  background-color: rgba(0, 0, 0, 0.5);
  padding: 20px;
  cursor: pointer;
  box-shadow: 0 0 5px #b466ff, 0 0 10px #b466ff; /* Purple box-shadow color */
  transition: 0.5s;
  margin: 2px;
  
  &:hover {
      transform: scale(1.1);
      box-shadow: 0 0 10px #b466ff, 0 0 20px #b466ff; /* Increase box-shadow spread on hover */
      z-index: 2;
  }
`;

function MenuButton({ buttonText, path }) {
    const navigate = useNavigate();

    function handleClick() {
        navigate(path);
    }

    return (
        <StyledMenuButton onClick={handleClick}>
            {buttonText}
        </StyledMenuButton>
    );
}

export default MenuButton;
