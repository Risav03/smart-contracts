// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBurner{
    function burnToEarn(uint256 tokenId, uint256 additional, address owner) external;
}

interface SimplyNFT{
    function ownerOf(uint256 tokenId) external view returns(address);
}

contract BurntoEarnCaller {
    IBurner public burner;
    SimplyNFT public simply;

    constructor(){
        burner = IBurner(0xbFFa5d24E38422934cA70eF5dc96d030E4B70607);
        simply = SimplyNFT(0x1a90102b680807CE176bE575479e4b824fD1F392);
    }

    function burn(uint256 tokenId, uint256 additional) public {
        require(msg.sender == simply.ownerOf(tokenId), "Not the owner");
        burner.burnToEarn(tokenId, additional, msg.sender);
    }

}