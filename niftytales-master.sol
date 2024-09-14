// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NiftyMaster is Ownable{

    constructor() Ownable(msg.sender){
        
    }

    address public notJPWallet;
    address public devWallet;

    uint8 public devPercent;

    uint256 public feePerMint;
    uint256 public feeForAuthor;

    mapping(address => bool) public whiteListed;

    function returnWhitelist(address add) public view returns (bool){
        return whiteListed[add];
    }

    function setFeePerMint(uint256 value) public {
        require(msg.sender == notJPWallet || msg.sender == devWallet, "Not allowed");
        feePerMint = value;
    }

    function returnfeeForAuthor() public view returns(uint256){
        return feeForAuthor;
    }

     function setFeeForAuthor(uint256 value) public {
        require(msg.sender == notJPWallet || msg.sender == devWallet, "Not allowed");
        feeForAuthor = value;
    }

    function addWhitelist(address adding) public {
        require(msg.sender == notJPWallet || msg.sender == devWallet, "Not allowed");
        whiteListed[adding] = true;
    }

    function removeWhitelist(address adding) public {
        require(msg.sender == notJPWallet || msg.sender == devWallet, "Not allowed");
        whiteListed[adding] = false;
    }

    function getFeePerMint() public view returns(uint256){
        return feePerMint;
    }
    
    function getDevPercent() public view returns (uint8){
        return devPercent;
    }

    function getNotJPWallet() public view returns (address){
        return notJPWallet;
    }

    function getDevWallet() public view returns (address){
        return devWallet;
    }

    function setDevPercent(uint8 amount) public {
        require(msg.sender == notJPWallet || msg.sender == devWallet, "Not allowed");
        require(amount >= 10, "Don't even try that");
        devPercent = amount;
    }

    function setNotJPWallet(address wallet) public {
        require(msg.sender == notJPWallet || msg.sender == devWallet, "Not allowed");
        notJPWallet = wallet;
    }

    function setDevWallet(address wallet) public onlyOwner {
        devWallet = wallet;
    }

    function boostBook() public payable {
        require(msg.value>0, "Want it all for free, huh?");


        payable(notJPWallet).transfer((msg.value*80)/100);
        payable(devWallet).transfer((msg.value*20)/100);
    
    }
}