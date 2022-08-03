// SPDX-FileCopyrightText: 2022 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "@openzeppelin/contracts-v4.4/token/ERC20/IERC20.sol";
import "./interfaces/ILido.sol";
import "./interfaces/ILidoEthErc20.sol";

/**
  * @title Wrapper around Lido for ERC20 token deposits
  */
abstract contract LidoErc20 is ILidoEthErc20 {
    uint256 constant internal _IS_ERC20 = 2;

    ILido public immutable LIDO;
    IERC20 public immutable STAKE_TOKEN;

    constructor(ILido _lido, IERC20 _stake_token) {
        require(address(_lido) != address(0), "ZERO_LIDO_ADDRESS");
        require(address(_stake_token) != address(0), "ZERO_STAKE_TOKEN_ADDRESS");
        
        LIDO = _lido;
        STAKE_TOKEN = _stake_token;
    }

    /**
    * @notice Send ETH to the pool
    */
    fallback() external payable {
        revert("NO_ETH_DEPOSITS");
    }

    /**
    * @dev Send mGNO to the pool with optional _referral parameter.
    * @notice Requires user approval.
    * @param _amount amount of mGNO.
    * @param _referral address of referral.
    * @return Amount of StETH shares generated
    */
    function _submitErc20(uint256 _amount, address _referral) internal returns (uint256) {
        _receiveStakeToken(_amount);
        return LIDO.submit(msg.sender, _amount, _referral, _IS_ERC20);
    }

    function _receiveStakeToken(uint256 _amount) internal {
        STAKE_TOKEN.transferFrom(msg.sender, address(LIDO), _amount);
    }

    /**
    * @dev Gets stake token balance of Lido contract
    */
    function _getStakeTokenBalance() internal view returns (uint256) {
        return STAKE_TOKEN.balanceOf(address(LIDO));
    }

    /**
    * @dev Approves stake token
    */
    function _stakeTokenApprove(address spender, uint256 amount) internal {
        STAKE_TOKEN.approve(spender, amount);
    }

    function STAKE_TOKEN_TYPE() external view returns (uint256) {
        return _IS_ERC20;
    }
}
