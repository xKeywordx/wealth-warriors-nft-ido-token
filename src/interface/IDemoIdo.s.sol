// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IDemoIdo is IERC721 {
    function calculateUserAllocation(address owner) external view returns (uint256);

    function getInvestorToAmountInvested(address user) external view returns (uint256);

    function getBalance(address _owner) external view returns (uint256);

    function getTotalAllocation() external view returns (uint256);

    function getTokenPrice() external view returns (uint256);

    function getAchillesAllocation() external view returns (uint256);

    function getAlexanderAllocation() external view returns (uint256);

    function getHannibalAllocation() external view returns (uint256);

    function getLeonidasAllocation() external view returns (uint256);

    function getAchillesSupply() external view returns (uint256);

    function getAlexanderSupply() external view returns (uint256);

    function getHannibalSupply() external view returns (uint256);

    function getLeonidasSupply() external view returns (uint256);
}
