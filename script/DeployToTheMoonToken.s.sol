// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ToTheMoonToken} from "../src/ToTheMoonToken.s.sol";

contract DeployToTheMoonToken is Script {
    function run() external {
        vm.startBroadcast();
        address demoIdoContractAddress = address(0x0000000000000000000000000000000000000000);

        ToTheMoonToken toTheMoon = new ToTheMoonToken(demoIdoContractAddress);

        console.log("ToTheMoonToken deployed to:", address(toTheMoon));

        vm.stopBroadcast();
    }
}
