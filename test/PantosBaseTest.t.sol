// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.23;

pragma abicoder v2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, Vm} from "forge-std/Test.sol";

import {PantosTypes} from "../src/interfaces/PantosTypes.sol";
import {PantosBaseToken} from "../src/PantosBaseToken.sol";
import {PantosForwarder} from "../src/PantosForwarder.sol";
import {PantosToken} from "../src/PantosToken.sol";

abstract contract PantosBaseTest is Test {
    uint256 public constant BLOCK_TIMESTAMP = 1000;
    uint256 public constant FEE_FACTOR_VALID_FROM_OFFSET = 600; // seconds added to current block time
    uint256 public constant FEE_FACTOR_VALID_FROM =
        BLOCK_TIMESTAMP + FEE_FACTOR_VALID_FROM_OFFSET;
    uint256 public constant SERVICE_NODE_STAKE_UNBONDING_PERIOD = 604800;
    uint256 public constant MINIMUM_TOKEN_STAKE = 10 ** 3 * 10 ** 8;
    uint256 public constant MINIMUM_SERVICE_NODE_STAKE = 10 ** 5 * 10 ** 8;
    uint256 public constant INITIAL_SUPPLY_PAN = 1_000_000_000;
    uint256 public constant MINIMUM_VALIDATOR_FEE_UPDATE_PERIOD = 0;
    // bitpandaEcosystemToken
    uint256 public constant INITIAL_SUPPLY_BEST = 1_000_000_000;

    // following is in sorted order, changing value will change order
    Vm.Wallet public validatorWallet = vm.createWallet("Validator");
    Vm.Wallet public validatorWallet2 = vm.createWallet("def");
    Vm.Wallet public validatorWallet3 = vm.createWallet("abc");
    Vm.Wallet public validatorWallet4 = vm.createWallet("xyz");

    address public validatorAddress = validatorWallet.addr;
    address public validatorAddress2 = validatorWallet2.addr;
    address public validatorAddress3 = validatorWallet3.addr;
    address public validatorAddress4 = validatorWallet4.addr;

    address public constant ADDRESS_ZERO = address(0);
    Vm.Wallet public testWallet = vm.createWallet("testWallet");
    Vm.Wallet public testWallet2 = vm.createWallet("testWallet2");

    address public transferSender = testWallet.addr;
    address public transferSender2 = testWallet2.addr;

    address constant TRANSFER_RECIPIENT =
        address(uint160(uint256(keccak256("TransferRecipient"))));
    address constant PANDAS_TOKEN_ADDRESS =
        address(uint160(uint256(keccak256("PandasTokenAddress"))));
    address constant SERVICE_NODE_ADDRESS =
        address(uint160(uint256(keccak256("ServiceNodeAddress"))));
    string constant SERVICE_NODE_URL = "service node url";
    string constant EXTERNAL_PANDAS_TOKEN_ADDRESS = "external token address";
    string constant OTHER_BLOCKCHAIN_TRANSACTION_ID =
        "other blockchain transaction ID";
    uint256 constant OTHER_BLOCKCHAIN_TRANSFER_ID = 0;
    uint256 constant NEXT_TRANSFER_ID = 0;
    uint256 constant TRANSFER_AMOUNT = 10;
    uint256 constant TRANSFER_FEE = 1;
    uint256 constant TRANSFER_NONCE = 0;
    uint256 constant TRANSFER_VALID_UNTIL = BLOCK_TIMESTAMP + 1;

    enum BlockchainId {
        TEST_CHAIN1, // 0
        TEST_CHAIN2 // 1
    }

    struct Blockchain {
        BlockchainId blockchainId;
        string name;
        uint256 feeFactor;
    }

    Blockchain public thisBlockchain =
        Blockchain(BlockchainId.TEST_CHAIN1, "TEST_CHAIN1", 800000);

    Blockchain public otherBlockchain =
        Blockchain(BlockchainId.TEST_CHAIN2, "TEST_CHAIN2", 900000);

    function deployer() public view returns (address) {
        return address(this);
    }

    // src: https://ethereum.stackexchange.com/a/83577
    function getRevertMsg(
        bytes memory _returnData
    ) public pure returns (string memory) {
        // If the _returnData length is less than 68, then the transaction
        // failed silently (without a revert message)
        if (_returnData.length < 68) return "";

        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    function transferRequest()
        public
        view
        returns (PantosTypes.TransferRequest memory)
    {
        return
            PantosTypes.TransferRequest(
                transferSender,
                TRANSFER_RECIPIENT,
                PANDAS_TOKEN_ADDRESS,
                TRANSFER_AMOUNT,
                SERVICE_NODE_ADDRESS,
                TRANSFER_FEE,
                TRANSFER_NONCE,
                TRANSFER_VALID_UNTIL
            );
    }

    function transferFromRequest()
        public
        view
        returns (PantosTypes.TransferFromRequest memory)
    {
        return
            PantosTypes.TransferFromRequest(
                uint256(otherBlockchain.blockchainId),
                transferSender,
                vm.toString(TRANSFER_RECIPIENT),
                PANDAS_TOKEN_ADDRESS,
                EXTERNAL_PANDAS_TOKEN_ADDRESS,
                TRANSFER_AMOUNT,
                SERVICE_NODE_ADDRESS,
                TRANSFER_FEE,
                TRANSFER_NONCE,
                TRANSFER_VALID_UNTIL
            );
    }

    function transferToRequest()
        public
        view
        returns (PantosTypes.TransferToRequest memory)
    {
        return
            PantosTypes.TransferToRequest(
                uint256(otherBlockchain.blockchainId),
                OTHER_BLOCKCHAIN_TRANSFER_ID,
                OTHER_BLOCKCHAIN_TRANSACTION_ID,
                vm.toString(transferSender),
                TRANSFER_RECIPIENT,
                EXTERNAL_PANDAS_TOKEN_ADDRESS,
                PANDAS_TOKEN_ADDRESS,
                TRANSFER_AMOUNT,
                TRANSFER_NONCE
            );
    }

    function onlyOwnerTest(
        address callee,
        bytes memory calldata_
    ) public virtual {
        string memory revertMessage = "Ownable: caller is not the owner";
        vm.startPrank(address(111));
        modifierTest(callee, calldata_, revertMessage);
    }

    function onlyNativeTest(address callee, bytes memory calldata_) public {
        string memory revertMessage = "PantosWrapper: only possible on "
        "the native blockchain";
        modifierTest(callee, calldata_, revertMessage);
    }

    function whenPausedTest(
        address callee,
        bytes memory calldata_
    ) public virtual {
        string memory revertMessage = "Pausable: not paused";
        modifierTest(callee, calldata_, revertMessage);
    }

    function whenNotPausedTest(
        address callee,
        bytes memory calldata_
    ) public virtual {
        string memory revertMessage = "Pausable: paused";
        modifierTest(callee, calldata_, revertMessage);
    }

    function modifierTest(
        address callee,
        bytes memory calldata_,
        string memory revertMessage
    ) public {
        (bool success, bytes memory response) = callee.call(calldata_);

        assertFalse(success);
        vm.expectRevert(bytes(revertMessage));
        assembly {
            revert(add(response, 32), mload(response))
        }
    }

    function assertSortedAscending(address[] memory addresses) public {
        if (addresses.length > 1) {
            for (uint i; i < addresses.length - 1; i++) {
                assertTrue(addresses[i] < addresses[i + 1]);
            }
        }
    }

    function mockIerc20_transferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 value,
        bool success
    ) public {
        vm.mockCall(
            tokenAddress,
            abi.encodeWithSelector(
                IERC20.transferFrom.selector,
                from,
                to,
                value
            ),
            abi.encode(success)
        );
    }

    function mockIerc20_transfer(
        address tokenAddress,
        address to,
        uint256 value,
        bool success
    ) public {
        vm.mockCall(
            tokenAddress,
            abi.encodeWithSelector(IERC20.transfer.selector, to, value),
            abi.encode(success)
        );
    }

    function mockIerc20_balanceOf(
        address tokenAddress,
        address account,
        uint256 balance
    ) public {
        vm.mockCall(
            tokenAddress,
            abi.encodeWithSelector(IERC20.balanceOf.selector, account),
            abi.encode(balance)
        );
    }

    function mockIerc20_allowance(
        address tokenAddress,
        address owner,
        address spender,
        uint256 balance
    ) public {
        vm.mockCall(
            tokenAddress,
            abi.encodeWithSelector(IERC20.allowance.selector, owner, spender),
            abi.encode(balance)
        );
    }

    function mockIerc20_totalSupply(
        address tokenAddress,
        uint256 value
    ) public {
        vm.mockCall(
            tokenAddress,
            abi.encodeWithSelector(IERC20.totalSupply.selector),
            abi.encode(value)
        );
    }

    function assertEq(bytes4[] memory a, bytes4[] memory b) public {
        assertEq(a.length, b.length);
        for (uint i; i < a.length; i++) {
            assertEq(a[i], b[i]);
        }
    }

    // exclude this class from coverage
    function test_nothing() public {}
}
