pragma solidity 0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract Fun {
    address public immutable adr = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    mapping (address=>bool) map;
    int public x=  10;

    constructor() {
        map[adr]= true;
    }

    function doSomthingM(int a) public {
        if (map[msg.sender]) {
            x = a;
        }
    }

    function doSomthingC(int a) public {
        if (adr == msg.sender) {
            x = a;
        }        
    }
}

contract Gas is Script {


    function run() public {
        Fun fun = new Fun();
        fun.doSomthingM(99); // not from owner
        fun.doSomthingC(88); // not from owner

        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        fun.doSomthingM(99); // from owner
        fun.doSomthingC(88); //from owner
    }
}
