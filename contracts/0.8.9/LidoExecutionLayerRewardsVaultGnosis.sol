// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "@openzeppelin/contracts-v4.4/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-v4.4/token/ERC20/utils/SafeERC20.sol";
import "./LidoExecutionLayerRewardsVaultErc20.sol";
import "./interfaces/IGPv2Settlement.sol";
import "./interfaces/IWXDAI.sol";
import "./interfaces/IGno.sol";

/**
 * @title A vault for temporary storage of execution layer rewards (MEV and tx priority fee)
 */
contract LidoExecutionLayerRewardsVaultGnosis is LidoExecutionLayerRewardsVaultErc20 {
    using SafeERC20 for IERC20;

    IGPv2Settlement public immutable GP_V2_SETTLEMENT;
    address public immutable GP_V2_VAULT_RELAYER;
    IWXDAI public immutable WXDAI;
    IGno public immutable GNO;
    address public immutable MGNO_WRAPPER;

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
        IWXDAI _wXDai,
        IGno _gno,
        address _mGnoWrapper
    )
        LidoExecutionLayerRewardsVaultErc20(_lido, _treasury, _stakeToken)
    {
        GP_V2_SETTLEMENT = _GPv2Settlement;
        GP_V2_VAULT_RELAYER = _GPv2VaultRelayer;
        WXDAI = _wXDai;
        GNO = _gno;
        MGNO_WRAPPER = _mGnoWrapper;
    }

    /**
      * Initiate sell of XDAI for GNO
      * @param _orderUid The unique identifier of the order to pre-sign.
      */
    function initiateSellOfNativeCurrencyForStakeToken(bytes calldata _orderUid) override external {
        uint256 balance = address(this).balance;
        require(balance > 0, "ZERO_BALANCE");

        WXDAI.deposit{ value: balance }();
        WXDAI.approve(GP_V2_VAULT_RELAYER, balance);
        GP_V2_SETTLEMENT.setPreSignature(_orderUid, false);
    }

    /**
      * Wrap GNO into mGNO
      */
    function _beforeStakeTokenTransfer() override internal {
        uint256 gnoBalance = _getGnoBalance();
        _convertGnoToMgno(gnoBalance);
    }

    function _convertGnoToMgno(uint256 _amount) internal {
        GNO.transferAndCall(address(MGNO_WRAPPER), _amount, "");
    }

    /**
    * @dev Gets GNO balance
    */
    function _getGnoBalance() internal view returns (uint256) {
        return GNO.balanceOf(address(this));
    }
}
