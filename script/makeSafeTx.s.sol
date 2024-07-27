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
import {stdJson} from "forge-std/StdJson.sol";

contract MakeSafeTX is Script {
    string public constant VERSION = "1.4.1";

    // keccak256(
    //     "EIP712Domain(uint256 chainId,address verifyingContract)"
    // );
    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH =
        0x47e79534a245952e8b16893a336b85a3d9ea9fa8c573f3d803afb92a79469218;

    // keccak256(
    //     "SafeTx(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 baseGas,uint256 gasPrice,address gasToken,address refundReceiver,uint256 nonce)"
    // );
    bytes32 private constant SAFE_TX_TYPEHASH =
        0xbb8310d486368db6bd6f849402fdd73ad53d316b5a4b2644ad6efe0f941286d8;

    address payable safeAddress =
        payable(0x31486d2483F49D5f506F480b4facb056EEFd6C2E);

    /**
     * @notice Returns the pre-image of the transaction hash (see getTransactionHash).
     * @param to Destination address.
     * @param value Ether value.
     * @param data Data payload.
     * @param operation Operation type.
     * @param safeTxGas Gas that should be used for the safe transaction.
     * @param baseGas Gas costs for that are independent of the transaction execution(e.g. base transaction fee, signature check, payment of the refund)
     * @param gasPrice Maximum gas price that should be used for this transaction.
     * @param gasToken Token address (or 0 if ETH) that is used for the payment.
     * @param refundReceiver Address of receiver of gas payment (or 0 if tx.origin).
     * @param _nonce Transaction nonce.
     * @return Transaction hash bytes.
     */
    function encodeTransactionData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) private view returns (bytes memory) {
        bytes32 safeTxHash = keccak256(
            abi.encode(
                SAFE_TX_TYPEHASH,
                to,
                value,
                keccak256(data),
                operation,
                safeTxGas,
                baseGas,
                gasPrice,
                gasToken,
                refundReceiver,
                _nonce
            )
        );
        return
            abi.encodePacked(
                bytes1(0x19),
                bytes1(0x01),
                domainSeparator(),
                safeTxHash
            );
    }

    function domainSeparator() public view returns (bytes32) {
        Safe safe = Safe(safeAddress); // wrap proxy
        return safe.domainSeparator(); // or hand write without any external call
    }

    function run() external {
        string memory root = vm.projectRoot();
        string memory path = string.concat(
            root,
            "/broadcast/deploySafe.s.sol/31337/dry-run/run-latest.json"
        );
        // Tx1559[] memory transactions = readTx1559s(path);
        string memory deployData = vm.readFile(path);
        // bytes memory parsedDeployData = vm.parseJson(deployData, ".transactions");
        bytes memory contractName = stdJson.parseRaw(
            deployData,
            ".transactions[0].contractName"
        );

        bytes memory arguments = stdJson.parseRaw(
            deployData,
            ".transactions[0].arguments"
        );

        uint256 value = 0;
        bytes memory data = abi.encodeWithSignature("pause()");
        uint256 nonce = 1;

        bytes memory encodedTransactionData = encodeTransactionData(
            address(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9), //address to,
            value, //  uint256 value,
            data, // bytes calldata data,
            Enum.Operation.Call, // Enum.Operation operation,
            0, // uint256 safeTxGas,
            0, // uint256 baseGas,
            0, // uint256 gasPrice,
            address(0), // address gasToken,
            payable(address(0)), // address refundReceiver,
            nonce // uint256 _nonce
        );
        console2.log(string(encodedTransactionData));
    }
}
