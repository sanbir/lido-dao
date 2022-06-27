// SPDX-FileCopyrightText: 2020 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.4.24;

import "../interfaces/IDepositContract.sol";


/**
  * @dev This is a mock. Don't use in production.
  */
contract DepositContractMock is IDepositContract {
    struct Call {
        bytes pubkey;
        bytes withdrawal_credentials;
        bytes signature;
        bytes32 deposit_data_root;
        uint256 value;
    }

    Call[] public calls;
    bytes32 internal depositRoot;
    address internal stakeToken;

    function deposit(
        bytes /* 48 */ pubkey,
        bytes /* 32 */ withdrawal_credentials,
        bytes /* 96 */ signature,
        bytes32 deposit_data_root,
        uint256 stake_amount
    )
        external
    {
        calls.push(Call(pubkey, withdrawal_credentials, signature, deposit_data_root, stake_amount));
    }

    function totalCalls() external view returns (uint256) {
        return calls.length;
    }

    function reset() external {
        calls.length = 0;
    }

    function get_deposit_root() external view returns (bytes32) {
        return depositRoot;
    }

    function set_deposit_root(bytes32 _newRoot) external {
        depositRoot = _newRoot;
    }

    function set_stake_token(address _stake_token) external {
        stakeToken = _stake_token;
    }

    function stake_token() public view returns (address) {
        return stakeToken;
    }
}
