// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract WealthWarriors is ERC721URIStorage, ERC721Enumerable, Ownable, VRFConsumerBaseV2, ReentrancyGuard {
    error WealthWarriors__WrongAmountSent();
    error WealthWarriors__ExceedsMaxSupply();
    error WealthWarriors__RangeOutOfBounds();
    error WealthWarriors__WithdrawalFailed();
    error WealthWarriors__AlreadyRolled();
    error WealthWarriors__MaxSupplyReached();

    event NftRequested(uint256 indexed requestId, address sender);
    event NftMinted(Rarity nftRarity, address minter);
    event RandomNumberAndRarity(uint256 indexed randomNumber, Rarity rarity);

    enum Rarity {
        Achilles,
        Alexander,
        Hannibal,
        Leonidas
    }

    mapping(uint256 tokenId => string tokenUri) private s_tokenIdToUri;
    mapping(uint256 requestId => address sender) private s_requestIdToSender;
    mapping(address owner => uint256 tokenId) public s_balances;
    mapping(uint256 => Rarity) public tokenIdToRarity;

    uint256 private constant MINT_PRICE = 1e15;
    uint256 private s_tokenCounter;
    uint256 private immutable i_maxSupply;
    uint256 private immutable i_veryRareRaritySupply; // 5% of total supply
    uint256 private immutable i_rareRaritySupply; // 15% of total supply
    uint256 private immutable i_uncommonRaritySupply; // 30% of total supply
    uint256 private immutable i_commonRaritySupply; // 50% of total supply

    // Track minted NFTs per rarity
    uint256 private s_veryRareNftsMinted;
    uint256 private s_rareNftsMinted;
    uint256 private s_uncommonNftsMinted;
    uint256 private s_commonlNftsMinted;

    //Chainlink VRF variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 keyHash,
        uint32 callbackGasLimit
    ) ERC721("WealthWarriors", "WW") Ownable(msg.sender) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = subscriptionId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenCounter = 0;
        i_maxSupply = 3000;
        i_veryRareRaritySupply = 150;
        i_rareRaritySupply = 450;
        i_uncommonRaritySupply = 900;
        i_commonRaritySupply = 1500;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        return super._increaseBalance(account, value);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    //////////////////////////////////////////////////////
    /////            MAIN FUNCTIONS                 /////
    ////////////////////////////////////////////////////

    function mintNft() public payable nonReentrant returns (uint256 requestId) {
        if (msg.value != MINT_PRICE) {
            revert WealthWarriors__WrongAmountSent();
        }
        if (s_tokenCounter == i_maxSupply) {
            revert WealthWarriors__ExceedsMaxSupply();
        }
        requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address nftOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;

        uint256 moddedRng = randomWords[0] % 100;

        (Rarity nftRarity, string memory uri) = getRarity(moddedRng);
        if (nftRarity == Rarity.Achilles) {
            s_veryRareNftsMinted++;
        } else if (nftRarity == Rarity.Alexander) {
            s_rareNftsMinted++;
        } else if (nftRarity == Rarity.Hannibal) {
            s_uncommonNftsMinted++;
        } else if (nftRarity == Rarity.Leonidas) {
            s_commonlNftsMinted++;
        }
        s_tokenCounter++;
        tokenIdToRarity[newTokenId] = nftRarity;
        _safeMint(nftOwner, newTokenId);
        _setTokenURI(newTokenId, uri);
        emit NftMinted(nftRarity, nftOwner);
    }

    function getRarity(uint256 moddedRng) public view returns (Rarity, string memory) {
        if (moddedRng < 5 && s_veryRareNftsMinted < i_veryRareRaritySupply) {
            return (
                Rarity.Achilles,
                "https://pink-suitable-platypus-128.mypinata.cloud/ipfs/QmTXVV9ZpMYU4XzDLD4eauBgQdwfThyAKWunfZFo9sEgBo"
            );
        } else if (moddedRng < 20 && s_rareNftsMinted < i_rareRaritySupply) {
            return (
                Rarity.Alexander,
                "https://pink-suitable-platypus-128.mypinata.cloud/ipfs/QmQwrudqxn8cTmRwx4Bi2WoCBBoapCQnsGNzjK2DCYBz8N"
            );
        } else if (moddedRng < 50 && s_uncommonNftsMinted < i_uncommonRaritySupply) {
            return (
                Rarity.Hannibal,
                "https://pink-suitable-platypus-128.mypinata.cloud/ipfs/QmVMQ2SVg5nQCMPctWnNHukpKBTgbmL8YMD5jdVKWKfn72"
            );
        } else if (moddedRng < 100 && s_commonlNftsMinted < i_commonRaritySupply) {
            return (
                Rarity.Leonidas,
                "https://pink-suitable-platypus-128.mypinata.cloud/ipfs/QmWMWvMFLAdPwsFjDSHFSfHqco2nfLMdVBJiCs5pPSF1nu"
            );
        } else {
            revert WealthWarriors__MaxSupplyReached();
        }
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert WealthWarriors__WithdrawalFailed();
        }
    }

    fallback() external {
        revert("Direct ETH transfers not allowed");
    }

    //////////////////////////////////////////////////////
    /////            Getter functions               /////
    ////////////////////////////////////////////////////

    function getBatchTokenRarities(uint256[] calldata tokenIds) public view returns (Rarity[] memory) {
        Rarity[] memory rarities = new Rarity[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            rarities[i] = tokenIdToRarity[tokenIds[i]];
        }
        return rarities;
    }

    function getNftRarity(uint256 tokenId) public view returns (Rarity) {
        return tokenIdToRarity[tokenId];
    }

    function getBalance(address owner) public view returns (uint256) {
        return s_balances[owner];
    }

    function getOwner(uint256 _tokenId) external view returns (address) {
        return ownerOf(_tokenId);
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getMaxSupply() public view returns (uint256) {
        return i_maxSupply;
    }

    function getRemainingSupply() public view returns (uint256) {
        return i_maxSupply - s_tokenCounter;
    }

    function getRequestIdToSender(uint256 requestId) public view returns (address) {
        return s_requestIdToSender[requestId];
    }

    function getMintPrice() public pure returns (uint256) {
        return MINT_PRICE;
    }

    function getVeryRareSupply() public view returns (uint256) {
        return i_veryRareRaritySupply;
    }

    function getRareSupply() public view returns (uint256) {
        return i_rareRaritySupply;
    }

    function getUncommonSupply() public view returns (uint256) {
        return i_uncommonRaritySupply;
    }

    function getCommonSupply() public view returns (uint256) {
        return i_commonRaritySupply;
    }

    function getVeryRareNftsMinted() public view returns (uint256) {
        return s_veryRareNftsMinted;
    }

    function getRareNftsMinted() public view returns (uint256) {
        return s_rareNftsMinted;
    }

    function getUncommonNftsMinted() public view returns (uint256) {
        return s_uncommonNftsMinted;
    }

    function getCommonNftsMinted() public view returns (uint256) {
        return s_commonlNftsMinted;
    }
}
