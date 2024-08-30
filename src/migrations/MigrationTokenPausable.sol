// SPDX-License-Identifier: GPL-3.0
// slither-disable-next-line solc-version
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

import {PantosBaseToken} from "../PantosBaseToken.sol";

/**
 * @title Pantos token
 */
contract MigrationTokenPausable is PantosBaseToken, ERC20Pausable {
    /**
     * @dev msg.sender receives all existing tokens.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 supply_
    ) PantosBaseToken(name_, symbol_, decimals_, msg.sender) {
        ERC20._mint(msg.sender, supply_);
        _pause();
    }

    function setPantosForwarder(address pantosForwarder) external onlyOwner {
        _setPantosForwarder(pantosForwarder);
    }

    /**
     * @dev See {PantosBaseToken-decimals} and {ERC20-decimals}.
     */
    function decimals()
        public
        view
        override(PantosBaseToken, ERC20)
        returns (uint8)
    {
        return PantosBaseToken.decimals();
    }

    /**
     * @dev See {PantosBaseToken-symbol} and {ERC20-symbol}.
     */
    function symbol()
        public
        view
        override(PantosBaseToken, ERC20)
        returns (string memory)
    {
        return PantosBaseToken.symbol();
    }

    /**
     * @dev See {PantosBaseToken-name} and {ERC20-name}.
     */
    function name()
        public
        view
        override(PantosBaseToken, ERC20)
        returns (string memory)
    {
        return PantosBaseToken.name();
    }

    /**
     * @dev See {Pausable-_pause)
     */
    function pause() external whenNotPaused onlyOwner {
        _pause();
    }

    /**
     * @dev See {Pausable-_unpause)
     */
    function unpause() external whenPaused onlyOwner {
        require(
            getPantosForwarder() != address(0),
            "PantosToken: PantosForwarder has not been set"
        );
        _unpause();
    }

    /**
     * @dev See {ERC20-_update}.
     */
    function _update(
        address sender,
        address recipient,
        uint256 amount
    ) internal override(ERC20, ERC20Pausable) {
        super._update(sender, recipient, amount);
    }
}
