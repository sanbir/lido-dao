// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "@openzeppelin/contracts-v4.4/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-v4.4/token/ERC20/utils/SafeERC20.sol";
import "./LidoExecutionLayerRewardsVaultErc20.sol";

/**
 * @title A vault for temporary storage of execution layer rewards (MEV and tx priority fee)
 */
contract LidoExecutionLayerRewardsVaultGnosis is LidoExecutionLayerRewardsVaultErc20 {
    using SafeERC20 for IERC20;

    /**
      * Ctor
      *
      * @param _lido the Lido token (stETH) address
      * @param _treasury the Lido treasury address (see ERC20/ERC721-recovery interfaces)
      * @param _stakeToken ERC-20 stake token address
      */
    constructor(address _lido, address _treasury, IERC20 _stakeToken) LidoExecutionLayerRewardsVaultErc20(_lido, _treasury, _stakeToken) {
    }

    /**
      * Initiate sell of native currency for stake token
      * @param _amount native currency amount
      */
    function initiateSellOfNativeCurrencyForStakeToken(uint256 _amount) virtual internal {

    }
}
