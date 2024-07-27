// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.26;
pragma abicoder v2;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Safe} from "@safe/Safe.sol";
import {SafeProxyFactory} from "@safe/proxies/SafeProxyFactory.sol";
import {SafeProxy} from "@safe/proxies/SafeProxy.sol";
import {MultiSend} from "@safe/libraries/MultiSend.sol";
import {Enum} from "@safe/libraries/Enum.sol";
import {TestNFT} from "./helpers/TestNFT.sol";

contract Submit is Script {
    address GNOSIS_SAFE_MASTER_COPY;
    address PROXY_FACTORY;
    address MULTISEND;

    uint256 public threshold = 2;
    mapping(address => bytes) public signatures;

    address[] public owners = [
        // ANVIL's default accounts in ascending order
        0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC, // 0x3c44... anvil2
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8, // 0x70... anvil1
        0x90F79bf6EB2c4f870365E785982E1f101E93b906 // 0x90...  anvil3
    ];
    uint256[] private privateKeys = [
        // ANVIL's default accounts private keys
        0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a,
        0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d,
        0x7c8521182947a0b1ffdcf5e5babd128afdf80fbc5cdacbb0baed1bc56e75a6da
    ];

    bytes[] private signaturesHardcoded = [
        // ANVIL's default accounts private keys
        bytes(hex"3b24f64a2dfd98576c949d04216aa8306e4ed96a0137dcdcdf5f7d94f883d8682941ab534d5e9b9f7391afdcbf32c4bd1bd3d0e38e3fb9a66d53d4544fb0e2fc1b"),
        bytes(hex"183a095b5657e5dd2d02ed3e0cb5e4f7d7a3be6708eb8eaec59226cc40c511383ff1f04f0d5f9885453d185f0f11e788db8deeae4af3ac2c9eb1c2c6c9375d5e1b"),
        bytes(hex"0f3f37c108e0a40bcb659b01d00f979fec772e28afd31bd8d2e1b31ac73e0b3d3b59a5dd6ec93ace2fc940a91ac8c238913360a55e71d56bdb23f82a8c57ea741c")
    ];

    /**
     * @notice Splits signature bytes into `uint8 v, bytes32 r, bytes32 s`.
     * @dev Make sure to perform a bounds check for @param pos, to avoid out of bounds access on @param signatures
     *      The signature format is a compact form of {bytes32 r}{bytes32 s}{uint8 v}
     *      Compact means uint8 is not padded to 32 bytes.
     * @param pos Which signature to read.
     *            A prior bounds check of this parameter should be performed, to avoid out of bounds access.
     * @param signatures Concatenated {r, s, v} signatures.
     * @return v Recovery ID or Safe signature type.
     * @return r Output value r of the signature.
     * @return s Output value s of the signature.
     */
    function signatureSplit(
        bytes memory signatures,
        uint256 pos
    ) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        /* solhint-disable no-inline-assembly */
        /// @solidity memory-safe-assembly
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := byte(0, mload(add(signatures, add(signaturePos, 0x60))))
        }
        /* solhint-enable no-inline-assembly */
    }

    function run() external {
        vm.startBroadcast();

        TestNFT testNft = TestNFT(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9);

        address payable safeAddress = payable(
            0x31486d2483F49D5f506F480b4facb056EEFd6C2E
        );
        Safe safe = Safe(safeAddress); // wrap proxy

        uint256 value = 0;

        bytes memory data;
        if (testNft.paused()) {
            data = abi.encodeWithSignature("unpause()");
        } else {
            data = abi.encodeWithSignature("unpause()");
        }

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

        console.log("nonce: %s", safe.nonce());
        console.logBytes32(txHash);

        // cast signed the transaction collected
        bytes memory collectedSignatures;
        for (uint256 i = 0; i < threshold; i++) {
            bytes memory signature = signaturesHardcoded[i];
            collectedSignatures = abi.encodePacked(
                collectedSignatures,
                signature
            );
        }

        // just printing the signers (logic from Gnosis safe)
        for (uint256 i = 0; i < threshold; i++) {
            uint256 v; // Implicit conversion from uint8 to uint256 will be done for v received from signatureSplit(...).
            bytes32 r;
            bytes32 s;
            (v, r, s) = signatureSplit(collectedSignatures, i);
            address currentOwner = ecrecover(txHash, uint8(v), r, s);
            console.log("v:%d; signer: %s", v, currentOwner);
            console.logBytes32(r);
            console.logBytes32(s);
        }

        console.logBytes(collectedSignatures);

        // Execute the transaction
        bool success = safe.execTransaction(
            address(testNft),
            value,
            data,
            Enum.Operation.Call,
            0,
            0,
            0,
            address(0),
            payable(address(0)),
            collectedSignatures
        );

        require(success, "Transaction failed");

        vm.stopBroadcast();
    }
}
