// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "@openzeppelin/contracts-v4.4/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-v4.4/token/ERC20/utils/SafeERC20.sol";
import "./LidoExecutionLayerRewardsVaultBase.sol";

/**
 * @title A vault for temporary storage of execution layer rewards (MEV and tx priority fee)
 */
abstract contract LidoExecutionLayerRewardsVaultErc20 is LidoExecutionLayerRewardsVaultBase {
    using SafeERC20 for IERC20;

    IERC20 public immutable STAKE_TOKEN;

    /**
      * Ctor
      *
      * @param _lido the Lido token (stETH) address
      * @param _treasury the Lido treasury address (see ERC20/ERC721-recovery interfaces)
      * @param _stakeToken ERC-20 stake token address
      */
    constructor(address _lido, address _treasury, IERC20 _stakeToken) LidoExecutionLayerRewardsVaultBase(_lido, _treasury) {
        STAKE_TOKEN = _stakeToken;
    }

    /**
      * @notice Withdraw all accumulated rewards to Lido contract
      * @dev Can be called only by the Lido contract
      * @param _maxAmount Max amount of ERC-20 to withdraw
      * @return amount of funds received as execution layer rewards (in stake tokens)
      */
    function withdrawRewards(uint256) external returns (uint256 amount) {
        require(msg.sender == LIDO, "ONLY_LIDO_CAN_WITHDRAW");

        uint256 balance = address(this).balance;
        if (amount > 0) {
            initiateSellOfNativeCurrencyForStakeToken(amount);
        }

        amount = _getStakeTokenBalance();
        if (amount > 0) {
            _transferStakeToken(LIDO, amount);
        }
        return amount;
    }

    /**
      * Initiate sell of native currency for stake token
      * @param _amount native currency amount
      */
    function initiateSellOfNativeCurrencyForStakeToken(uint256 _amount) virtual internal;

    /**
    * @dev Gets stake token balance of this contract
    */
    function _getStakeTokenBalance() internal view returns (uint256) {
        return STAKE_TOKEN.balanceOf(address(this));
    }

    /**
    * @dev Transfers stake token of this contract
    */
    function _transferStakeToken(address _recipient, uint256 _amount) internal {
        STAKE_TOKEN.transfer(_recipient, _amount);
    }
}
