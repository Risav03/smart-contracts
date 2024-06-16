// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IToken{
    function transferFrom(address from, address to, uint256 amount) external;
}

contract TacoCasino is Ownable {
    mapping(uint => address) public allowedTokens;
    mapping(uint => string) public allowedTokenNames;
    mapping(address => uint256) public withdrawAmount;

    constructor() Ownable(msg.sender){}

    function setWithdrawAmount(uint256 amount, address user) public onlyOwner{
        withdrawAmount[user] = withdrawAmount[user] + amount;
    }

    function setAllowedTokens(string memory name, address tokenAdd, uint index) public onlyOwner{
        allowedTokenNames[index] = name;
        allowedTokens[index] = tokenAdd;
    }

    function enterTokenGame(uint256 perBetAmount, uint256 trials, uint256 tokenIndex) public {
        address tokenSelected = allowedTokens[tokenIndex];
        IToken(tokenSelected).transferFrom(msg.sender, 0xc67Aa95B4AD61b6435d10567EC192e125aF7A0a0, perBetAmount*trials);
    }

    function enterMaticGame(uint256 perBetAmount, uint256 trials) public payable{
        require(msg.value >= perBetAmount*trials, "Insufficient funds");
    }

    function wonAmountWithdraw() public {
        payable(msg.sender).transfer(withdrawAmount[msg.sender]);
    }

    function withdraw(uint256 amount) public onlyOwner{
        require(address(this).balance > 0);
        uint256 ryanAmt = amount*700000000000000000/1000000000000000000;
        uint256 devAmt = (amount - ryanAmt);
        payable(owner()).transfer(ryanAmt);
        payable(0xc67Aa95B4AD61b6435d10567EC192e125aF7A0a0).transfer(devAmt);
    }
    
}