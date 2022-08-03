// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.12;

import "./ILidoEthErc20.sol";

/**
  * @title Wrapper around Lido for ERC-20 deposits
  */
interface ILidoGnosis is ILidoEthErc20 {

    /**
    * @dev Send GNO to the pool with optional _referral parameter.
    * @notice Requires user approval.
    * @param _amount amount of GNO.
    * @param _referral address of referral.
    * @return Amount of StETH shares generated
    */
    function submitGNO(uint256 _amount, address _referral) external returns (uint256);
}
