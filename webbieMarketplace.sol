// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://www.3xbuilds.com)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Degeneer03

pragma solidity 0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IWebbieNFTMaker{
    function safeMint(address to, uint256 tokenId) external;
    function tokenIdPublisher(uint256 tokenId) external view returns (address);
    function tokenIdPrice(uint256 tokenId) external view returns (uint256);
    function pauseMint(uint256 tokenId) external view returns (bool);
    function modifyPrice(uint256 tokenId, uint256 newPrice) external;
    function returnFee() external view returns(uint256);
}

contract WebbieMarketplace is Ownable{

    IWebbieNFTMaker public nftMaker;

    constructor() Ownable(msg.sender) {
        nftMaker = IWebbieNFTMaker();
    }

    function mint(uint256 tokenId) public payable {
        require(nftMaker.tokenIdPublisher(tokenId) != address(0), "Item does not exist");
        require(msg.value >= nftMaker.tokenIdPrice(tokenId), "Sending value less than price of item");
        require(nftMaker.pauseMint(tokenId) == false, "Mint has been paused for this item");

        safeMint(msg.sender, tokenId);

        payable(nftMaker.tokenIdPublisher(tokenId)).transfer((msg.value*(100-nftMaker.returnFee()))/100);
        payable(owner).transfer((msg.value*nftMaker.returnFee)/100);
    }

    function changePrice(uint256 tokenId, uint256 newPrice) public {
        require(msg.sender == nftMaker.tokenIdPublisher(tokenId), "You're not the owner of this asset");
        modifyPrice(tokenId, newPrice);
    }

}