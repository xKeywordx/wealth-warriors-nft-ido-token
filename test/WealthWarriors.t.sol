// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {WealthWarriors} from "../src/WealthWarriors.s.sol";
import {DeployWealthWarriors} from "../script/DeployWealthWarriors.s.sol";

contract WealthWarriorsTest is Test {
    DeployWealthWarriors public deployer;
    WealthWarriors public wealthWarriorsContract;
    address public user = makeAddr("user");
    uint256 public initialUserBalance = 10e18;
    uint256 public constant MINT_PRICE = 1e15;
    uint256 public s_tokenCounter;

    function setUp() public {
        deployer = new DeployWealthWarriors();
        wealthWarriorsContract = deployer.run();
    }

    function testNameIsCorrect() public view {
        string memory expectedName = "WealthWarriors";
        string memory actualName = wealthWarriorsContract.name();
        assert(keccak256(abi.encodePacked(expectedName)) == keccak256(abi.encodePacked(actualName)));
    }

    function testSymbolIsCorrect() public view {
        string memory expectedSymbol = "WW";
        string memory actualSymbol = wealthWarriorsContract.symbol();
        assert(keccak256(abi.encodePacked(expectedSymbol)) == keccak256(abi.encodePacked(actualSymbol)));
    }

    function testCanMint() public {
        vm.startPrank(user);
        vm.deal(user, initialUserBalance);
        uint256 startingUserBalance = user.balance;
        wealthWarriorsContract.mintNft{value: MINT_PRICE}();
        uint256 endingUserBalance = user.balance;
        console.log("Ending user balance is: ", endingUserBalance);
        assert(wealthWarriorsContract.balanceOf(user) == 1);
        assert(endingUserBalance == startingUserBalance - MINT_PRICE);
        assert(wealthWarriorsContract.getTokenCounter() == 1);
        assert(wealthWarriorsContract.getRemainingSupply() == 2999);
        vm.stopPrank();
    }
}
