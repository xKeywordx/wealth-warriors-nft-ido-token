// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IDemoIdo} from "./interface/IDemoIdo.s.sol";

contract ToTheMoonToken is ERC20, Ownable {
    uint256 public constant TOTAL_SUPPLY = 1e9 * 1e18; // 1 billion tokens with 18 decimals
    uint256 public constant TAX_PERCENTAGE = 1; // 1% tax on transactions
    address public taxAddress;
    IDemoIdo public s_demoIdoContract;

    event TaxCollected(uint256 taxAmount, address indexed from, address indexed to);

    constructor(address _demoIdoContract) ERC20("ToTheMoon", "TTM") Ownable(msg.sender) {
        s_demoIdoContract = IDemoIdo(_demoIdoContract);
        _mint(address(this), TOTAL_SUPPLY / 2);
        _mint(msg.sender, TOTAL_SUPPLY / 2);
        taxAddress = 0x0000000000000000000000000000000000000000;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    function withdrawTokens(address to, uint256 amount) public onlyOwner {
        require(balanceOf(address(this)) >= amount, "Insufficient balance in contract");
        _transfer(address(this), to, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (sender == owner() || recipient == owner()) {
            super._transfer(sender, recipient, amount);
        } else {
            // Calculate tax and net amount
            uint256 taxAmount = (amount * TAX_PERCENTAGE) / 100;
            uint256 netAmount = amount - taxAmount;

            // Transfer tax to the contract
            super._transfer(sender, taxAddress, taxAmount);
            emit TaxCollected(taxAmount, sender, taxAddress);

            // Transfer net amount to recipient
            super._transfer(sender, recipient, netAmount);
        }
    }

    function setTaxAddress(address _newTaxAddress) public onlyOwner {
        require(_newTaxAddress != address(0), "Invalid address");
        taxAddress = _newTaxAddress;
    }

    function distributeTokens(address[] calldata investors) public onlyOwner {
        uint256 tokenPrice = s_demoIdoContract.getTokenPrice();

        for (uint i = 0; i < investors.length; i++) {
            uint256 amountInvested = s_demoIdoContract.getInvestorToAmountInvested(investors[i]);
            uint256 tokensToDistribute = (amountInvested / tokenPrice) * 1e18;

            require(balanceOf(address(this)) >= tokensToDistribute, "Insufficient balance for distribution");

            _transfer(address(this), investors[i], tokensToDistribute);
        }
    }
}
