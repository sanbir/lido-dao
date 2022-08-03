// SPDX-FileCopyrightText: 2022 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.8.9;

import "@openzeppelin/contracts-v4.4/token/ERC20/IERC20.sol";
import "./LidoErc20.sol";
import "./interfaces/ILido.sol";
import "./interfaces/IMGno.sol";
import "./interfaces/IGno.sol";

/**
  * @title Wrapper around Lido for ERC20 token deposits
  */
contract LidoGnosis is LidoErc20 {

    IMGno public immutable MGNO;
    IGno public immutable GNO;
    address public immutable MGNO_WRAPPER;

    constructor(
        ILido _lido,
        IMGno _mgno,
        IGno _gno,
        address _mGnoWrapper
    ) LidoErc20(_lido, _mgno) {
        require(address(_mgno) != address(0), "ZERO_MGNO_ADDRESS");
        require(address(_gno) != address(0), "ZERO_GNO_ADDRESS");
        require(address(_mGnoWrapper) == address(0), "ZERO_MGNO_WRAPPER_ADDRESS");

        MGNO = _mgno;
        GNO = _gno;
        MGNO_WRAPPER = _mGnoWrapper;
    }

    /**
    * @dev Send mGNO to the pool with optional _referral parameter.
    * @notice Requires user approval.
    * @param _amount amount of mGNO.
    * @param _referral address of referral.
    * @return Amount of StETH shares generated
    */
    function submitMgno(uint256 _amount, address _referral) external returns (uint256) {
        return LidoErc20._submitErc20(_amount, _referral);
    }

    /**
    * @dev Gets stake token balance of Lido contract
    */
    function getMGNOBalance() internal view returns (uint256) {
        return LidoErc20._getStakeTokenBalance();
    }

    /**
     * @dev ERC677 callback on mGNO transferAndCall.
     * @param _from sender (user) address.
     * @param _value amount of the received tokens.
     * @param _data should be empty.
     */
    function onTokenTransfer(
        address _from,
        uint256 _value,
        bytes calldata _data
    ) external returns (bool)
    {
        address token = msg.sender;
        require(token == address(MGNO), "MGNO_ONLY");

        LIDO.submit(_from, _value, address(0), _IS_ERC20);

        return true;
    }

    /**
    * @dev Send GNO to the pool with optional _referral parameter.
    * @notice Requires user approval.
    * @param _amount amount of GNO.
    * @param _referral address of referral.
    */
    function submitGNO(uint256 _amount, address _referral) public returns (uint256) {
        _receiveGno(_amount);
        _convertGnoToMgno(_amount);
        return LIDO.submit(msg.sender, _amount * 32, _referral, _IS_ERC20); // 1 GNO = 32 mGNO
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
    */
    function submitGNOWithPermit(
        uint256 _amount,
        address _referral,
        uint256 _nonce,
        uint256 _expiry,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external
    {
        GNO.permit(
            msg.sender,
            address(LIDO),
            _nonce,
            _expiry,
            true,
            _v,
            _r,
            _s
        );

        submitGNO(_amount, _referral);
    }

    function _receiveGno(uint256 _amount) internal {
        GNO.transferFrom(msg.sender, address(LIDO), _amount);
    }

    function _convertGnoToMgno(uint256 _amount) internal {
        GNO.transferAndCall(address(MGNO_WRAPPER), _amount, "");
    }

    /**
    * @return the name of the token.
    */
    function name() public pure returns (string memory) {
        return "Liquid staked mGNO";
    }

    /**
     * @return the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public pure returns (string memory) {
        return "stmGNO";
    }
}
