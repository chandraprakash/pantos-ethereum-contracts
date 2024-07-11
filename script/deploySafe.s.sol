// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { Safe } from "@safe/Safe.sol";
import { SafeProxyFactory } from "@safe/proxies/SafeProxyFactory.sol";
import { SafeProxy } from "@safe/proxies/SafeProxy.sol";
import { MultiSend } from "@safe/libraries/MultiSend.sol";

contract DeploySafe is Script {
    address  GNOSIS_SAFE_MASTER_COPY; // = 0x41675C099F32341bf84BFc5382aF534df5C7461a; // Replace with actual address
    address  PROXY_FACTORY; // = 0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67; // Replace with actual address
    address  MULTISEND; // = 0x38869bf66a61cF6bDB996A6aE40D5853Fd43B526; // Replace with actual address

    address[] public owners;
    uint256 public threshold;

    function setUp() public {
        // Set up the owners and threshold
        owners = [
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        ];
        threshold = 1; // Number of required signatures
    }

    function run() external {
        vm.startBroadcast();

         // Deploy the Gnosis Safe master copy contract
        Safe gnosisSafe = new Safe();
        console.log("Gnosis Safe Master Copy deployed at:", address(gnosisSafe));
        GNOSIS_SAFE_MASTER_COPY = address(gnosisSafe);
        
        // Deploy the Proxy Factory contract
        SafeProxyFactory proxyFactory = new SafeProxyFactory();
        console.log("Proxy Factory deployed at:", address(proxyFactory));
        PROXY_FACTORY = address(proxyFactory);
        
        // Deploy the MultiSend contract
        MultiSend multiSend = new MultiSend();
        console.log("MultiSend deployed at:", address(multiSend));
        MULTISEND = address(multiSend);


        // // ProxyFactory proxyFactory = ProxyFactory(PROXY_FACTORY);
        // bytes memory data = abi.encodeWithSignature("setup(address[],uint256,address,bytes,address,address,uint256,address)", owners, threshold, address(0), "", address(0), address(0), 0, address(0));

        // // Deploy the proxy
        // address safeProxy = proxyFactory.createProxy(GNOSIS_SAFE_MASTER_COPY, data);


    // Prepare data for Gnosis Safe setup
        bytes memory data = abi.encodeWithSignature(
            "setup(address[],uint256,address,bytes,address,address,uint256,address)",
            owners,
            threshold,
            address(0),
            "",
            address(0),
            address(0),
            0,
            address(0)
        );

        // Use createChainSpecificProxyWithNonce to deploy the proxy
        uint256 saltNonce = 1;
        SafeProxy safeProxy = proxyFactory.createChainSpecificProxyWithNonce(GNOSIS_SAFE_MASTER_COPY, data, saltNonce);


        vm.stopBroadcast();

        console.log("Gnosis Safe deployed at:", address(safeProxy));
    }
}
