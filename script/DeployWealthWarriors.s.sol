// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {WealthWarriors} from "../src/WealthWarriors.s.sol";
import {Script, console} from "../lib/forge-std/src/Script.sol";

contract DeployWealthWarriors is Script {
    function run() external returns (WealthWarriors) {
        vm.startBroadcast();
        address vrfCoordinatorV2 = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
        uint64 subscriptionId = 1000; // you need to replace this random value with your actual subscription
        bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
        uint32 callbackGasLimit = 500000;

        WealthWarriors wealthWarriorsContract = new WealthWarriors(
            vrfCoordinatorV2,
            subscriptionId,
            keyHash,
            callbackGasLimit
        );
        vm.stopBroadcast();
        console.log("WealthWarriors deployed to:", address(wealthWarriorsContract));
        return wealthWarriorsContract;
    }
}
