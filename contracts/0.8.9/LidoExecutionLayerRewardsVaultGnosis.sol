// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "@openzeppelin/contracts-v4.4/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-v4.4/token/ERC20/utils/SafeERC20.sol";
import "./LidoExecutionLayerRewardsVaultErc20.sol";
import "./interfaces/IGPv2Settlement.sol";
import "./interfaces/IWXDAI.sol";

/**
 * @title A vault for temporary storage of execution layer rewards (MEV and tx priority fee)
 */
contract LidoExecutionLayerRewardsVaultGnosis is LidoExecutionLayerRewardsVaultErc20 {
    using SafeERC20 for IERC20;

    uint256 XDAI_AMOUNT_FOR_TX_FEES = 1 ether; // = 1 xDAI, arbitrary, can be other as well
    uint256 MIN_XDAI_AMOUNT_TO_SELL = 10 ether; // = 10 xDAI, arbitrary, can be other as well

    IGPv2Settlement public immutable GP_V2_SETTLEMENT;
    address public immutable GP_V2_VAULT_RELAYER;
    IWXDAI public immutable WXDAI;

    /**
      * Ctor
      *
      * @param _lido the Lido token (stETH) address
      * @param _treasury the Lido treasury address (see ERC20/ERC721-recovery interfaces)
      * @param _stakeToken ERC-20 stake token address
      */
    constructor(
        address _lido,
        address _treasury,
        IERC20 _stakeToken,
        IGPv2Settlement _GPv2Settlement,
        address _GPv2VaultRelayer,
        IWXDAI _wXDai
    )
        LidoExecutionLayerRewardsVaultErc20(_lido, _treasury, _stakeToken)
    {
        GP_V2_SETTLEMENT = _GPv2Settlement;
        GP_V2_VAULT_RELAYER = _GPv2VaultRelayer;
        WXDAI = _wXDai;
    }

    /**
      * Initiate sell of native currency for stake token
      * @param _amount xDAI amount in wei
      */
    function initiateSellOfNativeCurrencyForStakeToken(uint256 _amount) virtual internal {
        if (_amount < MIN_XDAI_AMOUNT_TO_SELL + XDAI_AMOUNT_FOR_TX_FEES) {
            return;
        }

        uint256 amountToSell = _amount - XDAI_AMOUNT_FOR_TX_FEES;

        WXDAI.deposit{ value: amountToSell }();
        WXDAI.approve(GP_V2_VAULT_RELAYER, amountToSell);

        bytes orderUid;
        // TODO
        GP_V2_SETTLEMENT.setPreSignature(orderUid, true);
    }
}
