//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {WealthWarriors} from "./WealthWarriors.s.sol";

contract MintWealthWarriors is Script {
    function run() external {
        address lastDeployment = DevOpsTools.get_most_recent_deployment("WealthWarriors", block.chainid);
        mintNftOnContract(lastDeployment);
    }

    function mintNftOnContract(address contractAddress) public payable {
        vm.startBroadcast();
        WealthWarriors(contractAddress).mintNft();
        vm.stopBroadcast();
    }
}
