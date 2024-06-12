// SPDX-License-Identifier: GPL-3.0
// slither-disable-next-line solc-version
pragma solidity 0.8.26;
pragma abicoder v2;

import "../PantosCoinWrapper.sol";

/**
 * @title Pantos-compatible token contract that wraps the Celo
 * blockchain network's Celo coin
 */
contract PantosCeloWrapper is PantosCoinWrapper {
    string private constant _NAME = "Celo (Pantos)";

    string private constant _SYMBOL = "panCELO";

    uint8 private constant _DECIMALS = 18;

    constructor(
        bool native
    ) PantosCoinWrapper(_NAME, _SYMBOL, _DECIMALS, native) {}
}
