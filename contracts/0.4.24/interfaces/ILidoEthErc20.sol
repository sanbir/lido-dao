// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.4.24;

/**
  * @title Wrapper around Lido
  * @dev For choosing between ERC-20 and native currency (ETH) deposits
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
    function name() public pure returns (string);

    /**
    * @return the symbol of the token, usually a shorter version of the
    * name.
    */
    function symbol() public pure returns (string);
}
