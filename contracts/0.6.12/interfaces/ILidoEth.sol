// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

import "./ILidoEthErc20.sol";

/**
  * @title Wrapper around Lido for native currency (ETH) deposits
  */
interface ILidoEth is ILidoEthErc20 {

    /**
    * @notice Send funds to the pool with optional _referral parameter
    * @dev This function is alternative way to submit funds. Supports optional referral address.
    * @return Amount of StETH shares generated
    */
    function submit(address _referral) external payable returns (uint256);
}
