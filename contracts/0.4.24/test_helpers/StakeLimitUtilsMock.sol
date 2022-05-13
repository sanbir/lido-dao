
// SPDX-FileCopyrightText: 2022 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.4.24;

import "../lib/StakeLimitUtils.sol";

contract StakeLimitUtilsMock {
    using StakeLimitUtils for uint256;

    function decodeStakeLimitSlot(uint256 _slotValue) public pure returns (
        uint96 maxStakeLimit,
        uint96 stakeLimitIncPerBlock,
        uint96 prevStakeLimit,
        uint32 prevStakeBlockNumber
    ) {
        return _slotValue.decodeStakeLimitSlot();
    }

    function encodeStakeLimitSlot(
        uint96 _maxStakeLimit,
        uint96 _stakeLimitIncPerBlock,
        uint96 _prevStakeLimit,
        uint32 _prevStakeBlockNumber
    ) public pure returns (uint256 ret) {
        return StakeLimitUtils.encodeStakeLimitSlot(_maxStakeLimit, _stakeLimitIncPerBlock, _prevStakeLimit, _prevStakeBlockNumber);
    }

     function calculateCurrentStakeLimit(uint256 _slotValue) public view returns(uint256 limit) {
         return _slotValue.calculateCurrentStakeLimit();
     }

    function updatePrevStakeLimit(uint256 _slotValue, uint256 _newPrevLimit) public view returns(uint256) {
        return _slotValue.updatePrevStakeLimit( _newPrevLimit);
    }

    function isStakingPaused(uint256 _slotValue) public pure returns(bool) {
        return _slotValue.isStakingPaused();
    }

    function isStakingRateLimited(uint256 _slotValue) public pure returns(bool) {
        return _slotValue.isStakingRateLimited();
    }
}