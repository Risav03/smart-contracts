// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IToken{
    function transferFrom(address from, address to, uint256 amount) external;
    function mint(address to, uint256 amount) external;
}

struct NFTArr {
    string tokenUri;
    uint256 tokenId;
}

interface SimplyNFT{
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns(address);
    function tokenURI(uint256 tokenId) external view returns(string memory);  
    function balanceOf(address owner) external view returns (uint256);
}


contract BurntoEarn is Ownable{
    SimplyNFT public simply;
    IToken public token;

    constructor(){
        simply = SimplyNFT(0x1a90102b680807CE176bE575479e4b824fD1F392);
        token = IToken(0xeFc5268C100530F50ff45Cd5C8c2e049254E8778);
    }

    function returnBalance() public view returns(uint256){
        return simply.balanceOf(msg.sender);

    }


    uint256 public rewardAmount = 100000000000000000000;
    address caller;


    function fetchTokenURI(uint multiple)public view returns(NFTArr[] memory){

        uint256 length = simply.balanceOf(msg.sender);
        NFTArr[] memory dataArr = new NFTArr[](length);

        uint256 j = 0;
        
        for(uint256 i = 400*multiple; i<400*(multiple+1); i++){
            try simply.ownerOf(i) returns (address){
                if(simply.ownerOf(i) == msg.sender){
                    dataArr[j] = NFTArr(simply.tokenURI(i), i);
                    j++;
                }
            }
            catch{
                continue;
            }
        }

        return dataArr;
    }

    function setRewardAmount(uint256 newAmount)public onlyOwner{
        rewardAmount = newAmount;
    }

    function setBurnToEarnCaller(address contractAddress) public onlyOwner{
        caller = contractAddress;
    }

    function burnToEarn(uint256 tokenId, uint256 additional, address owner) public {
        require(msg.sender == caller, "Not allowed to call directly");
        simply.burn(tokenId);
        token.mint(owner, rewardAmount+additional);
    }

    function batchBurn(uint[] memory tokenId, uint256 additional, address owner) public{
        require(msg.sender == caller, "Not allowed to call directly");

        for(uint256 i = 0; i<tokenId.length; i++){
            simply.burn(tokenId[i]);
        }
            token.mint(owner, rewardAmount+additional);
    }

}