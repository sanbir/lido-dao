// SPDX-FileCopyrightText: 2022 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "./interfaces/ILido.sol";
import "./interfaces/ILidoEthErc20.sol";

/**
  * @title Wrapper around Lido for native currency (ETH) deposits
  */
contract LidoEth is ILidoEthErc20 {
    uint256 constant internal _IS_ETH = 1;

    ILido public immutable LIDO;

    constructor(ILido _lido) {
        require(address(_lido) != address(0), "ZERO_LIDO_ADDRESS");
        
        LIDO = _lido;
    }

    /**
    * @notice Send funds to the pool
    * @dev Users are able to submit their funds by transacting to the fallback function.
    * Unlike vanilla Eth2.0 Deposit contract, accepting only 32-Ether transactions, Lido
    * accepts payments of any size. Submitted Ethers are stored in Buffer until someone calls
    * depositBufferedEther() and pushes them to the ETH2 Deposit contract.
    */
    fallback() external payable {
        // protection against accidental submissions by calling non-existent function
        require(msg.data.length == 0, "NON_EMPTY_DATA");

        LIDO.submit{value: msg.value}(msg.sender, msg.value, address(0), _IS_ETH);
    }

    /**
    * @notice Send funds to the pool with optional _referral parameter
    * @dev This function is alternative way to submit funds. Supports optional referral address.
    * @return Amount of StETH shares generated
    */
    function submit(address _referral) external payable returns (uint256) {
        return LIDO.submit{value: msg.value}(msg.sender, msg.value, _referral, _IS_ETH);
    }

    function STAKE_TOKEN_TYPE() external view returns (uint256) {
        return _IS_ETH;
    }

    /**
    * @return the name of the token.
    */
    function name() public pure returns (string memory) {
        return "Liquid staked Ether 2.0";
    }

    /**
     * @return the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public pure returns (string memory) {
        return "stETH";
    }
}
