// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IWealthWarriors is IERC721 {
    enum Rarity {
        Achilles,
        Alexander,
        Hannibal,
        Leonidas
    }

    function getNftRarity(uint256 tokenId) external view returns (Rarity);

    function getBatchTokenRarities(uint256[] calldata tokenIds) external view returns (Rarity[] memory);

    function getOwner(uint256 _tokenId) external view returns (address);

    function balanceOf(address owner) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}
