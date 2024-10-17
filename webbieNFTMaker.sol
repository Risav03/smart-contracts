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
    uint256 public ownerFee;

    address public minterContract;

    function setMinterContract(address minter) public onlyOwner{
        minterContract = minter;
    }

    function setOwnerFee(uint256 percentage) public onlyOwner{
        ownerFee = percentage;
    }

    function returnFee() public view returns(uint256){
        return ownerFee;
    }

    function createNFT(uint256 price) public {
        tokenIdPublisher[tokenId] = msg.sender;
        tokenIdPrice[tokenId] = price;

        tokenId++;
    }

    function safeMint(address to, uint256 _tokenId) external {
        require(msg.sender == minterContract, "Only minter contract can mint");
        _safeMint(to, _tokenId);
    }

    function returnPrice(tokenId) public view returns(uint256){
        return tokenIdPrice[tokenId];
    }

    function modifyPrice(uint256 tokenId, uint256 newPrice) public{
        require(minterContract = msg.sender, "This method can be called by the minter contract.");
        tokenIdPrice[tokenId] = newPrice;
    }

    function pause(uint256 tokenId) public {
        require(msg.sender == tokenIdPublisher[tokenId] || msg.sender == owner());

    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

}