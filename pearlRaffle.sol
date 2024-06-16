// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IPearl{
    function transferFrom(address from, address to, uint256 amount) external;
}

interface INft{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract PearlRaffle is Ownable{

    IPearl public pearlToken;
    INft public nftToTransfer;

    mapping(uint => uint256) public ticketLimit;
    mapping(uint => uint256) public ticketLimitPerWallet;
    mapping(uint => uint256) public ticketsSold;
    mapping(uint => uint256) public raffleTokenId;
    mapping(uint => address) public raffleContract;
    mapping(uint => mapping(address => uint256)) public walletHolding;
    mapping(uint => mapping(uint => address)) public enteredWallet;
    mapping(uint => uint256) public raffleEntryCost;

    mapping(uint => uint) public totalEntrants;

    mapping(uint => address) public lastNftWonContract;
    mapping(uint => uint256) public lastNftWonTokenId;
    mapping(uint => address) public lastWinners;

    uint randNonce = 0;

    constructor()Ownable(msg.sender){
        pearlToken = IPearl(0x58243b7c159d91Ef674CAEA7B98a483AA323aA8F);
    }

    function setRaffleItem(uint256 raffleIndex, address contractAddress, uint256 limitPerWallet, uint256 tokenId, uint256 tickets, uint256 cost) public onlyOwner{
        raffleContract[raffleIndex] = contractAddress;
        raffleTokenId[raffleIndex] = tokenId;
        ticketLimit[raffleIndex] = tickets;
        ticketLimitPerWallet[raffleIndex] = limitPerWallet;
        raffleEntryCost[raffleIndex] = cost;
    }

    function enterRaffle(uint256 raffleIndex, uint256 tickets) public {
        require(ticketLimit[raffleIndex] >= ticketsSold[raffleIndex] + tickets, "Exceeding total tickets");
        require(walletHolding[raffleIndex][msg.sender] + tickets <= ticketLimitPerWallet[raffleIndex], "Exceeding per wallet limit");

        ticketsSold[raffleIndex] = ticketsSold[raffleIndex] + tickets;

        if(walletHolding[raffleIndex][msg.sender] == 0){
            enteredWallet[raffleIndex][totalEntrants[raffleIndex]] = msg.sender;
            totalEntrants[raffleIndex] = totalEntrants[raffleIndex] +1;
        }

        walletHolding[raffleIndex][msg.sender] = walletHolding[raffleIndex][msg.sender] + tickets;
        
        uint256 cost = tickets*raffleEntryCost[raffleIndex];
        pearlToken.transferFrom(msg.sender, 0x6C1d642abA922C91cF98D6B8110cc30Afc949F0C, cost);
    }

    function chooseWinner(uint256 raffleIndex) public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % totalEntrants[raffleIndex];
    }

    function declareWinner(uint256 raffleIndex) public onlyOwner{
        randNonce++;
        uint256 winningIndex = chooseWinner(raffleIndex);
        address winningWallet = enteredWallet[raffleIndex][winningIndex];
        
        nftToTransfer = INft(raffleContract[raffleIndex]);
        nftToTransfer.safeTransferFrom(0x6C1d642abA922C91cF98D6B8110cc30Afc949F0C , winningWallet, raffleTokenId[raffleIndex]);
    
        lastWinners[raffleIndex] = winningWallet;
        lastNftWonTokenId[raffleIndex] = raffleTokenId[raffleIndex];
        lastNftWonContract[raffleIndex] = raffleContract[raffleIndex];

        deleteRaffle(raffleIndex);
    }

    function deleteRaffle(uint256 raffleIndex) public onlyOwner{
        

        delete ticketLimit[raffleIndex];
        delete ticketLimitPerWallet[raffleIndex];
        delete ticketsSold[raffleIndex];
        delete raffleTokenId[raffleIndex];
        delete raffleContract[raffleIndex];
        for(uint i = 0; i<totalEntrants[raffleIndex]; i++){
            address user = enteredWallet[raffleIndex][i];
            delete walletHolding[raffleIndex][user];
            delete enteredWallet[raffleIndex][i];
        }

        delete raffleEntryCost[raffleIndex];

        delete totalEntrants[raffleIndex];
    }



}