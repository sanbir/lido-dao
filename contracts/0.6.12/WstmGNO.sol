// SPDX-FileCopyrightText: 2021 Lido <info@lido.fi>

// SPDX-License-Identifier: GPL-3.0

/* See contracts/COMPILERS.md */
pragma solidity 0.6.12;

import "./WstEthBase.sol";
import "./interfaces/ILidoGnosis.sol";

contract WstmGNO is WstEthBase {

    ILidoGnosis public lidoGnosis;

    /**
     * @param _stETH address of the StETH token to wrap
     */
    constructor(IStETH _stETH, ILidoGnosis _lidoGnosis)
        public
        WstEthBase(_stETH, "Wrapped liquid staked mGNO", "wstmGNO")
    {
        lidoGnosis = _lidoGnosis;
    }
}
