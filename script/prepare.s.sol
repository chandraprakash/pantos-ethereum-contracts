// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;
pragma abicoder v2;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {Safe} from "@safe/Safe.sol";
import {SafeProxyFactory} from "@safe/proxies/SafeProxyFactory.sol";
import {SafeProxy} from "@safe/proxies/SafeProxy.sol";
import {MultiSend} from "@safe/libraries/MultiSend.sol";
import {Enum} from "@safe/libraries/Enum.sol";
import {TestNFT} from "./helpers/TestNFT.sol";

contract Prepare is Script {
    address GNOSIS_SAFE_MASTER_COPY;
    address PROXY_FACTORY;
    address MULTISEND;

    uint256 public threshold = 2;
    mapping(address => bytes) public signatures;

    address[] public owners = [
        // ANVIL's default accounts in ascending order
        0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC, // 0x3c44...
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8, // 0x70...
        0x90F79bf6EB2c4f870365E785982E1f101E93b906 // 0x90...
    ];
    uint256[] private privateKeys = [
        // ANVIL's default accounts private keys
        0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a,
        0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d,
        0x7c8521182947a0b1ffdcf5e5babd128afdf80fbc5cdacbb0baed1bc56e75a6da
    ];

    function run() external {
        vm.startBroadcast();

        // Deploy TestNFT and make safe wallet its owner
        TestNFT testNft = TestNFT(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9);

        address payable safeAddress = payable(
            0x31486d2483F49D5f506F480b4facb056EEFd6C2E
        );
        Safe safe = Safe(safeAddress); // wrap proxy
        // Get transaction hash for pausing TestNFT
        uint256 value = 0;
        bytes memory data = abi.encodeWithSignature("unpause()");

        console2.logBytes(data);

        bytes32 txHash = safe.getTransactionHash(
            address(testNft),
            value,
            data,
            Enum.Operation.Call,
            0,
            0,
            0,
            address(0),
            payable(address(0)),
            safe.nonce()
        );

        console2.logBytes32(txHash);

        testNft.unpause();

        // testNft.pause();

        // testNft.unpause();

        vm.stopBroadcast();
    }
}
