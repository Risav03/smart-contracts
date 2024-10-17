// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://www.3xbuilds.com)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Degeneer03

pragma solidity 0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IWebbieNFTMaker{
    function returnPrice(uint256 tokenId) external pure returns(uint256);
}

contract WebbieMarketplace is Ownable{

    IWebbieNFTMaker public nftMaker;


    constructor(
        nftMaker = IWebbieNFTMaker()
    ) Ownable(msg.sender) {}



}