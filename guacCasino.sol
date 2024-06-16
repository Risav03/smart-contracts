// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";


interface IGUAC{
    function transferFrom(address from, address to, uint256 amount) external;
    function mint(address to, uint256 amount) external;
    function balanceOf(address owner) external returns(uint256);
}

contract GuacCasino is Ownable{

    IGUAC public guac;
    
    mapping(address => uint256) public userDeposited; //tracks deposits+withdraws
    mapping(address => uint256) public userWallet; //tracks wins+loses+deposits+withdraws

    address public poolWallet;

    function setPoolWallet(address wallet) public onlyOwner{
        poolWallet = wallet;
    }

    constructor() Ownable(msg.sender){
        guac = IGUAC(0x6FE947Ffd91aE3A7C8a6090B692cA2BDeCD30269);
    }

    function depositGuac(uint256 amount) public {
        guac.transferFrom(msg.sender, poolWallet, amount);
        userDeposited[msg.sender] = userDeposited[msg.sender]+amount; 
        userWallet[msg.sender] = userWallet[msg.sender]+amount;
    }

    function enterGame(uint256 amount, address user) public {
        require(userWallet[user] >= amount, "Deposit more!");
        userWallet[user] = userWallet[user]-amount;
    }

    function transferWinnings(uint256 amount) public {
        userWallet[msg.sender] = userWallet[msg.sender]+amount;
    }


    function withdrawGuac(uint256 amount) public {
        require(amount <= userWallet[msg.sender],"Insufficient funds");
        if(amount > userDeposited[msg.sender]){
            guac.transferFrom(poolWallet, msg.sender, userDeposited[msg.sender]);
            guac.mint(msg.sender, amount-userDeposited[msg.sender]);
            userDeposited[msg.sender] = 0;
            userWallet[msg.sender] = userWallet[msg.sender] - amount;
        }
        else if(amount > guac.balanceOf(poolWallet)){
            guac.transferFrom(poolWallet, msg.sender, guac.balanceOf(poolWallet));
            guac.mint(msg.sender, amount-guac.balanceOf(poolWallet));
            userDeposited[msg.sender] = userDeposited[msg.sender] - amount;
            userWallet[msg.sender] = userWallet[msg.sender] - amount;
        }
        else{
            guac.transferFrom(poolWallet, msg.sender, amount);
            userDeposited[msg.sender] = userDeposited[msg.sender] - amount;
            userWallet[msg.sender] = userWallet[msg.sender] - amount;
        }
    }

}