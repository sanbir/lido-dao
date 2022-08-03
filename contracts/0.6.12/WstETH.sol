// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.6.12;

import "./WstEthBase.sol";
import "./interfaces/ILidoEth.sol";

contract WstETH is WstEthBase {

    ILidoEth public lidoEth;

    /**
     * @param _stETH address of the StETH token to wrap
     */
    constructor(IStETH _stETH, ILidoEth _lidoEth)
        public
        WstEthBase(_stETH, "Wrapped liquid staked Ether 2.0", "wstETH")
    {
        lidoEth = _lidoEth;
    }

    /**
    * @notice Shortcut to stake ETH and auto-wrap returned stETH
    */
    receive() external payable {
        uint256 shares = lidoEth.submit{value: msg.value}(address(0));
        _mint(msg.sender, shares);
    }
}
