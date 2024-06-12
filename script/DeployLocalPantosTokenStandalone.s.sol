// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;
pragma abicoder v2;

import "../src/PantosToken.sol";

import "./helpers/PantosTokenDeployer.s.sol";
import "./helpers/Constants.s.sol";

contract DeployLocalPantosTokenStandalone is PantosTokenDeployer {
    function run(address forwarder) external {
        vm.startBroadcast();

        PantosToken pantosToken = deployPantosToken(
            Constants.INITIAL_SUPPLY_PAN
        );
        initializePantosToken(pantosToken, PantosForwarder(forwarder));

        vm.stopBroadcast();
    }
}
