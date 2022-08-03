// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;


/**
  * @title LidoEthErc20 contract interface
  */
interface ILidoEthErc20 {
    /**
    * @return Stake token type.
    * @dev 1 - ETH, 2 = ERC-20
    */
    function STAKE_TOKEN_TYPE() external view returns (uint256);

    /**
    * @return the name of the token.
    */
    function name() external pure returns (string memory);

    /**
    * @return the symbol of the token, usually a shorter version of the
    * name.
    */
    function symbol() external pure returns (string memory);
}
