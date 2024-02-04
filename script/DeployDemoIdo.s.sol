// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DemoIdo} from "../src/DemoIdo.s.sol";

contract DeployDemoIdo is Script {
    function run() external {
        vm.startBroadcast();
        address wealthWarriorsContractAddress = address(0x0000000000000000000000000000000000000000);

        DemoIdo demoIdo = new DemoIdo(wealthWarriorsContractAddress);

        console.log("DemoIdo deployed to:", address(demoIdo));

        vm.stopBroadcast();
    }
}
