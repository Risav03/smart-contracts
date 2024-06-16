// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ISIMPLE{
    function transferFrom(address from, address to, uint256 amount) external;
}

interface INft{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

struct returnRaffle{
    string uri;
    uint256 participants;
    uint256 sold;
    uint256 maxAllowed;
    uint256 owned;
    uint256 maxOwnAllowed;
    uint256 price;
}

contract SimpleRaffle is Ownable{

    ISIMPLE public simple;
    INft public nftToTransfer;

    mapping(uint => uint256) public ticketLimit;
    mapping(uint => uint256) public ticketLimitPerWallet;
    mapping(uint => uint256) public ticketsSold;
    mapping(uint => uint256) public raffleTokenId;
    mapping(uint => address) public raffleContract;
    mapping(uint => mapping(address => uint256)) public walletHolding;
    mapping(uint => mapping(uint => address)) public enteredWallet;

    mapping(uint => uint256) public raffleEntrySimpleCost;
    mapping(uint => uint256) public raffleEntryMaticCost;

    mapping(uint => uint) public totalEntrants;

    mapping(uint => address) public lastNftWonContract;
    mapping(uint => uint256) public lastNftWonTokenId;
    mapping(uint => address) public lastWinners;

    uint public randNonce = 0;

    constructor(){
        simple = ISIMPLE(0xeFc5268C100530F50ff45Cd5C8c2e049254E8778);
    }

    function setSimpleRaffleItem(uint256 raffleIndex, address contractAddress, uint256 limitPerWallet, uint256 tokenId, uint256 tickets, uint256 cost) public onlyOwner{
        raffleContract[raffleIndex] = contractAddress;
        raffleTokenId[raffleIndex] = tokenId;
        ticketLimit[raffleIndex] = tickets;
        ticketLimitPerWallet[raffleIndex] = limitPerWallet;
        raffleEntrySimpleCost[raffleIndex] = cost;
    }

    function setMaticRaffleItem(uint256 raffleIndex, address contractAddress, uint256 limitPerWallet, uint256 tokenId, uint256 tickets, uint256 cost) public onlyOwner{
        raffleContract[raffleIndex] = contractAddress;
        raffleTokenId[raffleIndex] = tokenId;
        ticketLimit[raffleIndex] = tickets;
        ticketLimitPerWallet[raffleIndex] = limitPerWallet;
        raffleEntryMaticCost[raffleIndex] = cost;
    }

    function enterSimpleRaffle(uint256 raffleIndex, uint256 tickets) public {
        require(ticketLimit[raffleIndex] >= ticketsSold[raffleIndex] + tickets, "Exceeding total tickets");
        require(walletHolding[raffleIndex][msg.sender] + tickets <= ticketLimitPerWallet[raffleIndex], "Exceeding per wallet limit");

        ticketsSold[raffleIndex] = ticketsSold[raffleIndex] + tickets;

        if(walletHolding[raffleIndex][msg.sender] == 0){
            enteredWallet[raffleIndex][totalEntrants[raffleIndex]] = msg.sender;
            totalEntrants[raffleIndex] = totalEntrants[raffleIndex] +1;
        }

        walletHolding[raffleIndex][msg.sender] = walletHolding[raffleIndex][msg.sender] + tickets;
        
        uint256 cost = tickets*raffleEntrySimpleCost[raffleIndex];
        simple.transferFrom(msg.sender, 0x0708a59Ea3d6e8Dd1492fc2bBDC54A82905D9f59, cost);
    }

    function enterMaticRaffle(uint256 raffleIndex, uint256 tickets) public payable {
        require(ticketLimit[raffleIndex] >= ticketsSold[raffleIndex] + tickets, "Exceeding total tickets");
        require(walletHolding[raffleIndex][msg.sender] + tickets <= ticketLimitPerWallet[raffleIndex], "Exceeding per wallet limit");
        require(msg.value == tickets*raffleEntryMaticCost[raffleIndex], "Not enough value");

        ticketsSold[raffleIndex] = ticketsSold[raffleIndex] + tickets;

        if(walletHolding[raffleIndex][msg.sender] == 0){
            enteredWallet[raffleIndex][totalEntrants[raffleIndex]] = msg.sender;
            totalEntrants[raffleIndex] = totalEntrants[raffleIndex] +1;
        }

        walletHolding[raffleIndex][msg.sender] = walletHolding[raffleIndex][msg.sender] + tickets;
    
    }

    function chooseWinner(uint256 raffleIndex) public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % totalEntrants[raffleIndex];
    }

    function declareWinner(uint256 raffleIndex) public onlyOwner{
        randNonce++;
        uint256 winningIndex = chooseWinner(raffleIndex);
        address winningWallet = enteredWallet[raffleIndex][winningIndex];
        
        nftToTransfer = INft(raffleContract[raffleIndex]);
        nftToTransfer.safeTransferFrom(msg.sender , winningWallet, raffleTokenId[raffleIndex]);

        lastWinners[raffleIndex] = winningWallet;
        lastNftWonTokenId[raffleIndex] = raffleTokenId[raffleIndex];
        lastNftWonContract[raffleIndex] = raffleContract[raffleIndex];

        deleteRaffle(raffleIndex);
    }

    function withdraw() public onlyOwner{
        require(address(this).balance > 0);
        payable(owner()).transfer(address(this).balance);
    }

    function deleteRaffle(uint256 raffleIndex) public onlyOwner{

        delete ticketLimit[raffleIndex];
        delete ticketLimitPerWallet[raffleIndex];
        delete ticketsSold[raffleIndex];
        delete raffleTokenId[raffleIndex];
        delete raffleContract[raffleIndex];
        delete raffleEntryMaticCost[raffleIndex];
        for(uint i = 0; i<totalEntrants[raffleIndex]; i++){
            address user = enteredWallet[raffleIndex][i];
            delete walletHolding[raffleIndex][user];
            delete enteredWallet[raffleIndex][i];
        }

        delete raffleEntrySimpleCost[raffleIndex];
        delete totalEntrants[raffleIndex];
    }



}