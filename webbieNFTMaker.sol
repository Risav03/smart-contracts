// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://www.3xbuilds.com)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Degeneer03

pragma solidity 0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract WebbieNFTMaker is Ownable, ERC721, ERC721URIStorage{

    constructor(string memory uri) Ownable(msg.sender) {
        baseURI = uri;
    }

    mapping(uint256 => address) public tokenIdPublisher;
    mapping(uint256 => uint256) public tokenIdPrice;
    mapping(uint256 => bool) public pauseMint;

    string public baseURI;

    uint256 public tokenId;

    function createNFT(uint256 price) public {
        tokenIdPublisher[tokenId] = msg.sender;
        tokenIdPrice[tokenId] = price;

        tokenId++;
    }

    function mint(uint256 tokenId) public payable {
        require(tokenIdPublisher[tokenId] != address(0), "Item does not exist");
        require(msg.value >= tokenIdPrice[tokenId], "Sending value less than price of item");
        require(pauseMint[tokenId] == false, "Mint has been paused for this item");

        _mint(msg.sender, tokenId, "");
    }

    function returnPrice(tokenId) public pure returns(uint256){
        return tokenIdPrice[tokenId];
    }

    function modifyPrice(uint256 newPrice) public{
        require(tokenIdPublisher[tokenId] = msg.sender, "You're not the owner of this asset.");
        tokenIdPrice[tokenId] = newPrice;
    }

    function pause(uint256 tokenId) public {
        require(msg.sender == tokenIdPublisher[tokenId] || msg.sender == owner());

    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

}