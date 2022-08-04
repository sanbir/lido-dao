// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "@openzeppelin/contracts-v4.4/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-v4.4/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-v4.4/token/ERC20/utils/SafeERC20.sol";
import "./LidoExecutionLayerRewardsVaultBase.sol";

interface ILido {
    /**
      * @notice A payable function supposed to be called only by LidoExecLayerRewardsVault contract
      * @dev We need a dedicated function because funds received by the default payable function
      * are treated as a user deposit
      */
    function receiveELRewards() external payable;
}


/**
 * @title A vault for temporary storage of execution layer rewards (MEV and tx priority fee)
 */
contract LidoExecutionLayerRewardsVaultEth is LidoExecutionLayerRewardsVaultBase {
    using SafeERC20 for IERC20;

    /**
      * Ctor
      *
      * @param _lido the Lido token (stETH) address
      * @param _treasury the Lido treasury address (see ERC20/ERC721-recovery interfaces)
      */
    constructor(address _lido, address _treasury) LidoExecutionLayerRewardsVaultBase(_lido, _treasury) {
    }

    /**
      * @notice Withdraw all accumulated rewards to Lido contract
      * @dev Can be called only by the Lido contract
      * @param _maxAmount Max amount of ETH to withdraw
      * @return amount of funds received as execution layer rewards (in wei)
      */
    function withdrawRewards(uint256 _maxAmount) external override returns (uint256 amount) {
        require(msg.sender == LIDO, "ONLY_LIDO_CAN_WITHDRAW");

        uint256 balance = address(this).balance;
        amount = (balance > _maxAmount) ? _maxAmount : balance;
        if (amount > 0) {
            ILido(LIDO).receiveELRewards{value: amount}();
        }
        return amount;
    }
}
