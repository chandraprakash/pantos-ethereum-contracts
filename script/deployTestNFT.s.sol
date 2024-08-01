// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;
pragma abicoder v2;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {TestNFT} from "./helpers/TestNFT.sol";

contract DeployTestNFT is Script {

    function run() external {
        vm.startBroadcast();
        address owner = 0xF81Eb173cd2494c20F3763eF834dd19790c64179;

        // Deploy TestNFT
        TestNFT testNft = new TestNFT(owner);

        console.log(testNft.paused());

        for (uint i; i< 5; i++) {
            testNft.mint(owner, i);
        }

        vm.stopBroadcast();
    }
}
