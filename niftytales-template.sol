// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

struct holders {
    address holder;
    uint256 holding;
}

interface IMaster{
        function getDevPercent() external view returns (uint8);
        function getDevWallet() external view returns (address);
        function getNotJPWallet() external view returns (address);
        function getFeePerMint() external view returns (uint256);
        function returnWhitelist(address add) external view returns (bool);
        function returnfeeForAuthor() external view returns (uint256);
    }

interface IContract{
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);

}

contract NiftyTalesTemplate is ERC1155, Ownable {
    using Strings for uint256;

    IMaster public master;
    IContract public outsideContract;

    uint256 public BOOK = 0;
    string public name;
    string public symbol;
    string public baseURI;

    mapping(uint256 => uint256) public tokenIdPrice;
    mapping(uint256 => uint256) public tokenIdMaxMints;
    mapping(uint256 => uint256) public tokenIdMinted;

    mapping(uint256 => mapping(address => uint256)) public tokenIdMintedByAddress;
    mapping(uint256 => mapping(uint256 => address)) public addressesHoldingTheTokenId;
    mapping(uint256 => uint256) public totalHoldersOfTokenId;

    mapping(uint256 => uint256) public tokenIdLastMintingTime;
    mapping(uint256 => address) public tokenIdRestrictedToContract;

    mapping(uint256 => bool) public pauseMinting;

    mapping(uint256 => uint256) public maxMintsPerWallet;
    
    constructor(string memory _name, string memory _symbol, string memory _uri) Ownable(msg.sender) ERC1155(_uri) payable {
        master = IMaster(0xBA334807c9b41Db493cD174aaDf3A8c7E8a823AF);
        if(IMaster(0xBA334807c9b41Db493cD174aaDf3A8c7E8a823AF).returnWhitelist(msg.sender) == false){
            require(msg.value >= IMaster(0xBA334807c9b41Db493cD174aaDf3A8c7E8a823AF).returnfeeForAuthor(),"Pay the fee");
        }
        name = _name;
        symbol = _symbol;
        baseURI = _uri;

    }

    function changePrice(uint256 tokenId, uint256 price) public onlyOwner{
        tokenIdPrice[tokenId] = price;
    }

    function changeMaxMints(uint256 tokenId, uint256 maxMints) public onlyOwner{
        tokenIdMaxMints[tokenId] = maxMints;
    }

    function changeLastMintingTime(uint256 tokenId, uint256 time) public onlyOwner{
        tokenIdLastMintingTime[tokenId] = time;
    }

    function changeMaxMintsPerWallet(uint256 tokenId, uint256 max) public onlyOwner{
        maxMintsPerWallet[tokenId] = max;
    }

    function pauseMint(uint256 tokenId) public {
        require(msg.sender == owner() || msg.sender == master.getNotJPWallet() || msg.sender == master.getDevWallet(), "Not allowed");
        pauseMinting[tokenId] = true;
    }

    function unpauseMint(uint256 tokenId) public {
        require(msg.sender == owner() || msg.sender == master.getNotJPWallet() || msg.sender == master.getDevWallet(), "Not allowed");
        pauseMinting[tokenId] = false;
    }

    function setPrice(uint256 tokenId, uint256 price, uint256 maxMints, uint256 time, address contractAdd) public onlyOwner {
        tokenIdPrice[tokenId] = price;
        tokenIdMaxMints[tokenId] = maxMints;
        tokenIdLastMintingTime[tokenId] = time;
        tokenIdRestrictedToContract[tokenId] = contractAdd;
    }

    function publishBook(uint256 tokenId, uint256 price, uint256 maxMints, uint256 time, address contractAdd, uint256 maxMintsWallet) public onlyOwner {
        setPrice(tokenId, price, maxMints, time, contractAdd);
        pauseMinting[tokenId] = false;
        maxMintsPerWallet[tokenId] = maxMintsWallet;
        BOOK++;
    }

    function returnHolders(uint256 tokenId) public view returns (holders[] memory){
        holders[] memory dataArr = new holders[](totalHoldersOfTokenId[tokenId]);

        for(uint256 i = 0; i<totalHoldersOfTokenId[tokenId]; i++){
            dataArr[i] = holders(addressesHoldingTheTokenId[tokenId][i], tokenIdMintedByAddress[tokenId][addressesHoldingTheTokenId[tokenId][i]]);
        }

        return dataArr;
    }
    
    function mint(uint256 amount, uint256 tokenId) public payable {
        require(tokenId < BOOK, "Token does not exist");
        require(amount > 0, "Amount must be greater than 0");
        require(pauseMinting[tokenId] == false, "Token ID has been paused");
        if(maxMintsPerWallet[tokenId] > 0){
            require(tokenIdMintedByAddress[tokenId][msg.sender] + amount <= maxMintsPerWallet[tokenId], "Exceeding max mints per wallet limit");
        }

        if(tokenIdMaxMints[tokenId] != 0){
            require(tokenIdMinted[tokenId] + amount <= tokenIdMaxMints[tokenId], "Exceeding max mints");
        }
        require(msg.value >= (tokenIdPrice[tokenId] + master.getFeePerMint())*amount, "Insufficient funds");

        if(tokenIdLastMintingTime[tokenId] > 0){
            require(block.timestamp < tokenIdLastMintingTime[tokenId], "time exceeded");
        }

        if(tokenIdRestrictedToContract[tokenId] != address(0)){
            require(outsideContract.balanceOf(msg.sender) > 0, "Not elligible for this mint");
        }

        _mint(msg.sender, tokenId, amount, "");

        if(tokenIdMintedByAddress[tokenId][msg.sender] == 0){
            addressesHoldingTheTokenId[tokenId][totalHoldersOfTokenId[tokenId]] = msg.sender;
            totalHoldersOfTokenId[tokenId] += 1;
        }
        tokenIdMintedByAddress[tokenId][msg.sender] = tokenIdMintedByAddress[tokenId][msg.sender] + amount;
        tokenIdMinted[tokenId] = tokenIdMinted[tokenId] + amount;

        uint256 publisherAmount = msg.value - (master.getFeePerMint()*amount);
        uint256 devAmount = ((master.getFeePerMint()*amount)*master.getDevPercent())/100;
        uint256 notJpAmount = ((master.getFeePerMint()*amount)*(100-master.getDevPercent()))/100;

        payable(owner()).transfer(publisherAmount);
        payable(master.getDevWallet()).transfer(devAmount);
        payable(master.getNotJPWallet()).transfer(notJpAmount);
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }
}