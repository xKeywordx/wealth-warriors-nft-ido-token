// //SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IWealthWarriors} from "./interface/IWealthWarriors.sol";

contract DemoIdo is Ownable, ReentrancyGuard {
    error DemoIdo__WithdrawalFailed();
    error DemoIdo__AmountExceedsAllocation();
    error DemoIdo__AlreadyBoughtTokens();

    event DemoIdo__TokensBought(address, uint256 amount);
    event DemoIdo__UserWhitelisted(address);

    mapping(uint256 tokenId => address owner) private tokenIdToOwner;
    mapping(address investor => uint256 amount) public investorToAmountInvested;
    mapping(IWealthWarriors.Rarity rarity => uint256) private rarityToAllocation;

    // Whitelist
    address[] whitelist;
    address[] public investors;

    // Allocations will be set in the constructor
    uint256 private immutable i_totalAllocation;
    uint256 private immutable i_tokenPrice;
    uint256 private s_achillesAllocation;
    uint256 private s_alexanderAllocation;
    uint256 private s_hannibalAllocation;
    uint256 private s_leonidasAllocation;

    // NFTs supply
    uint256 private s_achillesSupply;
    uint256 private s_alexanderSupply;
    uint256 private s_hannibalSupply;
    uint256 private s_leonidasSupply;

    // Helper variables
    address public collectorAddress;
    IWealthWarriors public s_wealthWarriorsContract;

    constructor(address _wealthWarriorsContract) Ownable(msg.sender) {
        s_wealthWarriorsContract = IWealthWarriors(_wealthWarriorsContract);
        i_totalAllocation = 25e18; // total funding round allocation
        i_tokenPrice = 2e14;
        // total allocations per rarity
        s_achillesAllocation = 10e18;
        s_alexanderAllocation = 7e18;
        s_hannibalAllocation = 5e18;
        s_leonidasAllocation = 3e18;
        collectorAddress = address(this);
        // total nfts supply
        s_achillesSupply = 150;
        s_alexanderSupply = 450;
        s_hannibalSupply = 900;
        s_leonidasSupply = 1500;
    }

    function buyToken() public payable nonReentrant {
        require(isWhitelisted(msg.sender), "Not whitelisted");
        if (investorToAmountInvested[msg.sender] != 0) {
            revert DemoIdo__AlreadyBoughtTokens();
        }
        uint256 userAllocation = calculateUserAllocation(msg.sender);
        if (msg.value > userAllocation) {
            revert DemoIdo__AmountExceedsAllocation();
        }
        uint256 amountInvested = msg.value;
        investorToAmountInvested[msg.sender] = amountInvested;
        investors.push(msg.sender);
        emit DemoIdo__TokensBought(msg.sender, amountInvested);
    }

    function setCollectorAddress(address _newAddress) public onlyOwner {
        require(_newAddress != address(0), "Invalid address");
        collectorAddress = _newAddress;
    }

    function getWhitelisted() external {
        if (s_wealthWarriorsContract.balanceOf(msg.sender) > 0) {
            whitelist.push(msg.sender);
        }
        emit DemoIdo__UserWhitelisted(msg.sender);
    }

    function isWhitelisted(address _address) public view returns (bool) {
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert DemoIdo__WithdrawalFailed();
        }
    }

    fallback() external {
        revert("Direct ETH transfers not allowed");
    }

    //////////////////////////////////////////////
    /////       Calculate allocations       /////
    ////////////////////////////////////////////

    function calculateUserAllocation(address owner) public view returns (uint256) {
        uint256 totalAllocation = 0;
        uint256 numberOfNFTs = s_wealthWarriorsContract.balanceOf(owner);

        for (uint256 i = 0; i < numberOfNFTs; i++) {
            uint256 tokenId = s_wealthWarriorsContract.tokenOfOwnerByIndex(owner, i);
            IWealthWarriors.Rarity rarity = s_wealthWarriorsContract.getNftRarity(tokenId);
            totalAllocation += _getNftRarityAllocation(rarity);
        }

        return totalAllocation;
    }

    // function _calculateNftRarityAllocation(IWealthWarriors.Rarity rarity) internal view returns (uint256) {
    //     uint256 allocationPerNft = _getNftRarityAllocation(rarity);
    //     return allocationPerNft;
    // }

    function _getNftRarityAllocation(IWealthWarriors.Rarity rarity) internal view returns (uint256) {
        if (rarity == IWealthWarriors.Rarity.Achilles) {
            return _calculateOneAchillesAllocation();
        } else if (rarity == IWealthWarriors.Rarity.Alexander) {
            return _calculateOneAlexanderAllocation();
        } else if (rarity == IWealthWarriors.Rarity.Hannibal) {
            return _calculateOneHannibalAllocation();
        } else if (rarity == IWealthWarriors.Rarity.Leonidas) {
            return _calculateOneLeonidasAllocation();
        }

        // Default case (shouldn't happen)
        revert("Invalid rarity");
    }

    function _calculateOneAchillesAllocation() internal view returns (uint256) {
        uint256 allocationPerNft = s_achillesAllocation / s_achillesSupply;
        return allocationPerNft;
    }

    function _calculateOneAlexanderAllocation() internal view returns (uint256) {
        uint256 allocationPerNft = s_alexanderAllocation / s_alexanderSupply;
        return allocationPerNft;
    }

    function _calculateOneHannibalAllocation() internal view returns (uint256) {
        uint256 allocationPerNft = s_hannibalAllocation / s_hannibalSupply;
        return allocationPerNft;
    }

    function _calculateOneLeonidasAllocation() internal view returns (uint256) {
        uint256 allocationPerNft = s_leonidasAllocation / s_leonidasSupply;
        return allocationPerNft;
    }

    //////////////////////////////////////////////
    /////         Getter functions          /////
    ////////////////////////////////////////////

    function getBalance(address _owner) public view returns (uint256) {
        return s_wealthWarriorsContract.balanceOf(_owner);
    }

    function getTotalAllocation() public view returns (uint256) {
        return i_totalAllocation;
    }

    function getTokenPrice() public view returns (uint256) {
        return i_tokenPrice;
    }

    function getAchillesAllocation() public view returns (uint256) {
        return s_achillesAllocation;
    }

    function getAlexanderAllocation() public view returns (uint256) {
        return s_alexanderAllocation;
    }

    function getHannibalAllocation() public view returns (uint256) {
        return s_hannibalAllocation;
    }

    function getLeonidasAllocation() public view returns (uint256) {
        return s_leonidasAllocation;
    }

    function getAchillesSupply() public view returns (uint256) {
        return s_achillesSupply;
    }

    function getAlexanderSupply() public view returns (uint256) {
        return s_alexanderSupply;
    }

    function getHannibalSupply() public view returns (uint256) {
        return s_hannibalSupply;
    }

    function getLeonidasSupply() public view returns (uint256) {
        return s_leonidasSupply;
    }

    function getInvestorToAmountInvested(address user) public view returns (uint256) {
        return investorToAmountInvested[user];
    }
}
