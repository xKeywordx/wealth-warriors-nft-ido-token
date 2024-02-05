# This repo contains 3 main contracts. one NFT Collection, one Demo IDO, and one dummy ERC20 Token.

# Repository Overview

This repository contains three main contracts: an NFT Collection named Wealth Warriors, a Demo IDO (Initial DEX Offering), and a dummy ERC20 Token. Each contract serves a distinct purpose, leveraging various standards and technologies.

In brief, the NFT collection is the main contract and the core of the ecosystem. By owning an NFT from the WealthWarriors collection, a user is eligible to participate in IDOs. A user's allocation will be calculated based on the number of NFTs that he holds and based on the rarity of each NFT. The rarer the NFT, the bigger the allocation in IDOs.

The DemoIdo contract is a crowdsale contract that sets an amount to be raised and sets certain limits in place. The contract will also keep track of the amounts invested by each investor.

The token contract, in my demo example called ToTheMoonToken, is an implementation of an ERC20 token, with additional functionality such as a way to distribute the initial supply based on the amount that each investor put in during the IDO phase, a withdraw function, and a tex mechanism.

I am also using 2 interfaces in order to tie things together.

## Contracts Overview

### 1. `WealthWarriors.s.sol`- The NFT Collection

Wealth Warriors is an NFT collection that incorporates several key features and standards to create a smooth minting experience. The collection is capped at 3000 tokens supply, with 4 categories of NFT rarities.
Achilles - very rare, 150 tokens/ Alexander The Great - rare, 450 tokens / Hannibal - uncommon - 900 tokens/ Leonidas - common - 1500 tokens.
The rarity of the NFTs will be used to calculate the total allocation for a user during IDOs.
Below are the details of its implementation.

#### Features and Standards:

- Utilizes `ERC721Enumerable`, `ERC721URIStorage`, `Ownable`, and `ReentrancyGuard` standards from OpenZeppelin.
- Integrates `VRFConsumerBaseV2` from Chainlink to obtain verifiable random numbers for NFT minting, ensuring a fair distribution process.

#### NFT Rarities:

- The contract implements 4 NFTs, of different rarities. Achilles - very rare, Alexander The Great - rare, Hannibal - uncommon, Leonidas - common, each NFT having a different drop rate that's being calculated in the `getRarity` function.

#### Supply Management:

- The owner of the contract can set a total supply for the collection and also set a different supply for each of the different rarities inside the constructor by using the `i_maxSupply`, `i_veryRareRaritySupply`, `i_rareRaritySupply`, `i_uncommonRaritySupply`, `i_commonRaritySupply` variables inside the constructor.

#### Minting Functionality:

- The `mintNFT` function is using Chainlink's VRF in order to get a provable random number, and mint the NFTs in a random way, ensuring that the distribution process is fair, and all users have a chance of minting rare NFTs.

- After each call, the `s_tokenCounter` will increase, keeping track of how many NFTs have been minted so far, and also the supply for each rarity will be increased, making sure that the number of rare NFTs can not be minted beyond the maximum amount that was set in the constructor.

- The `mintNFT` function also sets the `tokenURI` of each NFT, and keeps track of the rarity of each NFT minted. I chose to do this, because the allocations of users for each IDO depend on the rarity of the NFTs that they hold, so the IDO contract needs a way to access the rarity of each minted NFT. This is also why I had to use `ERC721Enumerable`. This library extends the standard ERC721 library and allows the contract to keep track of the rarity of each NFT.

#### Additional Functions:

- The contract also has a `withdraw` function that can be called by the owner of the contract in order to redeem the funds.

- The contract has a `fallback` function that reverts on transfer, because I do not want my contract to directly accept Ether, I want users to call the `mintNft` function if they want to mint.

- The contract has a number of getter functions that allow users to keep track of the current status of the contract, some examples being `getNftRarity` (which will be used in the DemoIDO contract too), `getOwner`, `getTokenCounter`, etc.

### 2. `IWealthWarriors.s.sol` - An Interface For The Main NFT Contract

#### Features and Standards:

- Utilizes `IERC721` standard from OpenZeppelin.

#### Additional Info:

- I've built this interface because the `DemoIdo.s.sol` contract needs to be aware of the rarity of each NFT inside the `WealthWarriors.s.sol` contract.

- I didn't want to import all the code of the original contract because using an interface is more gas efficient, improves modularity, and interoperability for future developments

### 3. `DemoIdo.s.sol`- The IDO contract

The DemoIdo contract is a simulation for an Initial Dex Offering based on the WealthWarriors NFT collection. It uses the number of NFTs held by a wallet, and the rarity of each NFT to calculate the total allocation that a user can invest.

#### Features and Standards:

- Utilizes `Ownable`, and `ReentrancyGuard` standards from OpenZeppelin.
- Utilizes the `IWealthWarriors.s.sol` interface to interact with the main `Wealth Warriors` NFT collection.

#### The setup:

- In order for a user to participate in the IDO, they need to hold at least 1 NFT from the WealthWarriors collection. If they fulfill this requirement, they can whitelist themselves by calling the `getWhitelisted` function.

- The contract allows the owner to set the a total amount for the funding round allocation in the constructor `i_totalAllocation`, set a token price `i_tokenPrice` for the IDO token, and set the total allocation for each NFT rarity by changing the values of `s_achillesAllocation`, `s_alexanderAllocation`, `s_hannibalAllocation`, `s_leonidasAllocation` variables. Additionally, the owner must set the total supply for each NFT rarity, because these will be needed when calculating the total allocation for each user.

#### Calculate user allocation:

- The `calculateUserAllocation` function will take the address of a user as an input parameter, and it will check the balance of this address. It will then loop through the user's address to get the number of NFTs that the user holds from the Wealth Warriors NFT collection, and get the rarity of each NFT. It will then call a series of internal functions that will calculate the total allocation of that user.

- In my example, the total funding round allocation is 25 Ether, and the allocation for the `Achilles` NFT holders is 10 ETH (40% of the total allocation). Provided that the supply of `s_achillesSupply` NFTs is 150 tokens, the allocation for each Achilles NFT that the user holds is 10 ether / 150 tokens = 0.066666666 ether.

- If a user holds 3 Achilles NFTs, then his total allocation will be `0.066666666 * 3 = 0.199999998 ether`.

#### Additional Functions:

- The contract allows the owner to set a different `collector` address that receives the funds of the crowdsale.

- The contract has a `fallback` function that reverts on transfer, because I do not want my contract to directly accept Ether, I want users to call the `buyToken` function if they want to invest.

### 4. `IDemoIdo.s.sol` - An Interface For The DemoIdo contract

#### Features and Standards:

- Utilizes the `IERC721` standard from OpenZeppelin.

#### Additional Info:

- I've built this interface because the `ToTheMoonToken.s.sol` contract needs to be aware of the amounts that each investor put into the crowdsale in order to distribute the tokens at TGE.

- I didn't want to import all the code of the original contract because using an interface is more gas efficient, improves modularity, and interoperability for future developments

### 5. Dummy ERC20 Token - `ToTheMoonToken.s.sol`

A demo ERC20 token, that checks the amounts invested by users during the IDO phase, and distributes tokens accordingly.

#### Features and Standards:

- Utilizes `ERC20`, and `Ownable` standards from OpenZeppelin.
- Utilizes the `IDemoIdo.s.sol` interface to interact with the main `Wealth Warriors` NFT collection.

#### Setup:

- Sets the total supply for the token.
- Sets a tax percentage. It is a taxable token, meaning that whenever a transfer that is not made by the owner occurs, the tax percentage will be deducted from the user's balance.
- Sets the initial distribution of tokens inside the constructor and a tax address that will collect the fees.

#### Additional Functions:

- Has a `withdrawTokens` function that allows the owner to get the tokens out of the contract.

- Has a `setTaxAddress` function that allows the owner to change the tax address (the address that collects transfer fees).

- Has a `distributeTokens` function that will check the amounts invested by each user during the IDO phase inside the `DemoIdo.s.sol` contract and then calculate how many tokens each user should get, before transferring them out.

## Put it to the test

- Clone the repo.
- You will need to create a new Chainlink VRF subscription and replace my placeholder subscription number with yours in the `WealthWarriors` deploy script.
- Before deploying the `DemoIdo.s.sol` contract, you will need to get the contract address of the `WealthWarriors.s.sol` contract that you recently deployed and put that into the deploy script of DemoIdo.
- Before deploying the `ToTheMoonToken.s.sol` contract, you will need to get the contract address of the `DemoIdo.s.sol` contract that you recently deployed and put that into the deploy script of ToTheMoonToken.
- Now, you should be able to mint an NFT in the first contract, check your allocation inside the IDO, whitelist yourself and participate in the IDO, and then you can distribute TTM tokens to the address that participated in the IDO.

