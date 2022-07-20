// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/lib/math/SafeMath.sol";
import "@aragon/os/contracts/lib/math/SafeMath64.sol";

import "./interfaces/IMGno.sol";
import "./interfaces/IGno.sol";
import "./interfaces/IMGnoWrapper.sol";

contract LidoOnGnosis {

    using SafeMath for uint256;
    using UnstructuredStorage for bytes32;

    bytes32 internal constant MGNO_POSITION = keccak256("lido.Lido.mGNO");
    bytes32 internal constant GNO_POSITION = keccak256("lido.Lido.GNO");
    bytes32 internal constant MGNO_WRAPPER_POSITION = keccak256("lido.Lido.MGNO_WRAPPER");

    /**
    * @dev Initialize LidoOnGnosis:
    * @param _mGno mGNO contract
    * @param _gno GNO contract
    */
    function _initialize(
        IMGno _mGno,
        IGno _gno,
        IMGnoWrapper _mGnoWrapper
    )
    internal
    {
        MGNO_POSITION.setStorageAddress(address(_mGno));
        GNO_POSITION.setStorageAddress(address(_gno));
        MGNO_WRAPPER_POSITION.setStorageAddress(address(_mGnoWrapper));
    }

    /**
    * @dev Send mGNO to the pool with optional _referral parameter.
    * @notice Requires user approval.
    * @param _amount amount of mGNO.
    * @param _referral address of referral.
    * @return Amount of StETH shares generated
    */
    function submit(uint256 _amount, address _referral) external returns (uint256) {
        _receiveMgno(_amount);
        return _submit(_amount, _referral, msg.sender);
    }

    /**
     * @dev ERC677 callback on mGNO transferAndCall.
     * @param from sender (user) address.
     * @param value amount of the received tokens.
     * @param data should be empty.
     */
    function onTokenTransfer(
        address from,
        uint256 value,
        bytes data
    ) external returns (bool)
    {
        address token = msg.sender;
        require(token == address(getMGNO()), "mGNO only");

        _submit(value, address(0), from);

        return true;
    }

    /**
    * @dev Send GNO to the pool with optional _referral parameter.
    * @notice Requires user approval.
    * @param _amount amount of GNO.
    * @param _referral address of referral.
    * @return Amount of StETH shares generated
    */
    function submitGNO(uint256 _amount, address _referral) public returns (uint256) {
        _receiveGno(_amount);
        _convertGnoToMgno(_amount);
        return _submit(_amount.mul(32), _referral, msg.sender); // 1 GNO = 32 mGNO
    }

    /**
    * @dev Send GNO to the pool with optional _referral parameter.
    * @notice Does not require user approval. Accepts offline signature instead.
    * @param _amount amount of GNO.
    * @param _referral address of referral.
    * @param _nonce The nonce taken from `nonces(_holder)` public getter.
    * @param _expiry The allowance expiration date (unix timestamp in UTC).
    * Can be zero for no expiration. Forced to zero if `_allowed` is `false`.
    * Note that timestamps are not precise, malicious miner/validator can manipulate them to some extend.
    * Assume that there can be a 900 seconds time delta between the desired timestamp and the actual expiration.
    * @param _v A final byte of signature (ECDSA component).
    * @param _r The first 32 bytes of signature (ECDSA component).
    * @param _s The second 32 bytes of signature (ECDSA component).
    * @return Amount of StETH shares generated
    */
    function submitGNOWithPermit(
        uint256 _amount,
        address _referral,
        uint256 _nonce,
        uint256 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override
    {
        getGNO().permit(
            msg.sender,
            address(this),
            _nonce,
            _expiry,
            true,
            _v,
            _r,
            _s
        );

        return submitGNO(_amount, _referral);
    }

    function _receiveMgno(uint256 _amount) internal {
        getMGNO().transferFrom(msg.sender, address(this), _amount);
    }

    function _receiveGno(uint256 _amount) internal {
        getGNO().transferFrom(msg.sender, address(this), _amount);
    }

    function _convertGnoToMgno(uint256 _amount) internal {
        bool success = getGNO().transferAndCall(address(getMGNOWrapper()), _amount, "");
        require(success, "GNO_TO_MGNO_CONVERT_ERROR");
    }

    /**
    * @notice Gets mGNO contract handle
    */
    function getMGNO() public view returns (IMGno) {
        return IMGno(MGNO_POSITION.getStorageAddress());
    }

    /**
    * @notice Gets GNO contract handle
    */
    function getGNO() public view returns (IGno) {
        return IGno(GNO_POSITION.getStorageAddress());
    }

    /**
    * @notice Gets GNO to mGNO wrapper contract handle
    */
    function getMGNOWrapper() public view returns (IMGno) {
        return IMGnoWrapper(MGNO_WRAPPER_POSITION.getStorageAddress());
    }

    /**
    * @dev Gets mGNO balance of this contract
    */
    function getMgnoBalance() internal view returns (uint256) {
        return getMGNO().balanceOf(address(this));
    }

    /**
    * @dev Approves mGNO
    */
    function mGnoIncreaseAllowance(address spender, uint256 addedValue) internal {
        getMGNO().increaseAllowance(spender, addedValue);
    }

    /**
    * @dev Process user deposit, mints liquid tokens and increase the pool buffer
    * @param _amount amount of mGNO.
    * @param _referral address of referral.
    * @param _to address of shares recipient.
    * @return amount of StETH shares generated
    */
    function _submit(uint256 _amount, address _referral, address _to) internal returns (uint256);
}
