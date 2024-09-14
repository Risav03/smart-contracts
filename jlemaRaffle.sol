// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ICLEAN{
    function transferFrom(address from, address to, uint256 amount) external;
}

interface INft{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

struct returnRaffle{
    address contractAdd;
    uint256 tokenId;
    uint256 participants;
    uint256 sold;
    uint256 maxAllowed;
    uint256 owned;
    uint256 maxOwnAllowed;
    uint256 cleanPrice;
    uint256 maticPrice;
    string collectionLink;
}

struct endedRaffle{
    address contractAdd;
    uint256 tokenId;
    address winner;
}

contract JlemaRaffle is Ownable{

    ICLEAN public clean;
    INft public nftToTransfer;

    uint public activeRaffles;
    uint public endedRaffles;

    mapping(uint => uint256) public ticketLimit;
    mapping(uint => uint256) public ticketLimitPerWallet;
    mapping(uint => uint256) public ticketsSold;
    mapping(uint => uint256) public raffleTokenId;
    mapping(uint => address) public raffleContract;
    mapping(uint => mapping(address => uint256)) public walletHolding;
    mapping(uint => mapping(uint => address)) public enteredWallet;
    mapping(uint => string) public collectionLink;
    mapping(uint => uint256) public raffleEntryCleanCost;
    mapping(uint => uint256) public raffleEntryMaticCost;

    mapping(uint => uint) public totalEntrants;

    mapping(uint => address) public lastNftWonContract;
    mapping(uint => uint256) public lastNftWonTokenId;
    mapping(uint => address) public lastWinners;

    uint public randNonce = 0;

    constructor() Ownable(msg.sender){
        clean = ICLEAN(0xeF2c6201f085E972fbaD4FA08beF4BaB660DAc33);
    }

    function deleteRaffle(uint256 raffleIndex) public onlyOwner{

            for(uint i = raffleIndex; i<activeRaffles;i++){
                ticketLimit[i] = ticketLimit[i+1];
                ticketLimitPerWallet[i] = ticketLimitPerWallet[i+1];
                ticketsSold[i] = ticketsSold[i+1];
                raffleTokenId[i] = raffleTokenId[i+1];
                raffleContract[i] = raffleContract[i+1];
                collectionLink[i] = collectionLink[i+1];
                raffleEntryCleanCost[i] = raffleEntryCleanCost[i+1];
                raffleEntryMaticCost[i] = raffleEntryMaticCost[i+1];
                totalEntrants[i] = totalEntrants[i+1];

                for(uint j = 0; j<totalEntrants[i]; j++){
                    enteredWallet[i][j] = enteredWallet[i+1][j];
                    walletHolding[i][enteredWallet[i+1][j]] = walletHolding[i+1][enteredWallet[i+1][j]];
                }
            }

            activeRaffles--;
    }

    function fetchActiveRaffles() public view returns (returnRaffle[] memory){
        returnRaffle[] memory dataArr = new returnRaffle[](activeRaffles);

        for(uint256 i = 0; i < activeRaffles; i++){
            dataArr[i] = returnRaffle(raffleContract[i], raffleTokenId[i], totalEntrants[i], ticketsSold[i], ticketLimit[i], walletHolding[i][msg.sender], ticketLimitPerWallet[i], raffleEntryCleanCost[i], raffleEntryMaticCost[i], collectionLink[i]);
        }

        return dataArr;
    }

    function fetchEndedRaffles() public view returns (endedRaffle[] memory){
        endedRaffle[] memory dataArr = new endedRaffle[](10);

        for(uint256 i = 0; i<10; i++){
            dataArr[i] = endedRaffle(lastNftWonContract[i], lastNftWonTokenId[i], lastWinners[i]);
        }

        return dataArr;
    }

    function setRaffleItem(uint256 raffleIndex, address contractAddress, uint256 limitPerWallet, string memory link, uint256 tokenId, uint256 tickets, uint256 cleanCost, uint256 maticCost) public onlyOwner{
        raffleContract[raffleIndex] = contractAddress;
        raffleTokenId[raffleIndex] = tokenId;
        ticketLimit[raffleIndex] = tickets;
        collectionLink[raffleIndex] = link;
        ticketLimitPerWallet[raffleIndex] = limitPerWallet;
        raffleEntryCleanCost[raffleIndex] = cleanCost;
        raffleEntryMaticCost[raffleIndex] = maticCost;
    }

    function enterCleanRaffle(uint256 raffleIndex, uint256 tickets) public {
        require(ticketLimit[raffleIndex] >= ticketsSold[raffleIndex] + tickets, "Exceeding total tickets");
        require(walletHolding[raffleIndex][msg.sender] + tickets <= ticketLimitPerWallet[raffleIndex], "Exceeding per wallet limit");

        ticketsSold[raffleIndex] = ticketsSold[raffleIndex] + tickets;

        if(walletHolding[raffleIndex][msg.sender] == 0){
            enteredWallet[raffleIndex][totalEntrants[raffleIndex]] = msg.sender;
            totalEntrants[raffleIndex] = totalEntrants[raffleIndex] +1;
        }

        walletHolding[raffleIndex][msg.sender] = walletHolding[raffleIndex][msg.sender] + tickets;
        
        uint256 cost = tickets*raffleEntryCleanCost[raffleIndex];
        clean.transferFrom(msg.sender, 0x0708a59Ea3d6e8Dd1492fc2bBDC54A82905D9f59, cost);
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

        lastWinners[endedRaffles] = winningWallet;
        lastNftWonTokenId[endedRaffles] = raffleTokenId[raffleIndex];
        lastNftWonContract[endedRaffles] = raffleContract[raffleIndex];

        if(endedRaffles != 9){
            endedRaffles++;
        }
        else{
            endedRaffles = 0;
        }
        
        deleteRaffle(raffleIndex);
    }

    function withdraw() public onlyOwner{
        require(address(this).balance > 0);
        uint256 ownerAmount = 91*address(this).balance/100;
        uint256 devAmount = address(this).balance - ownerAmount;
        payable(owner()).transfer(ownerAmount);
        payable(0x1ce256752fBa067675F09291d12A1f069f34f5e8).transfer(devAmount/3);
        payable(0xa92B24AC60A6B381E0eC2DD17d2a3339Cda24D84).transfer(devAmount/3);
        payable(0x1ce256752fBa067675F09291d12A1f069f34f5e8).transfer(devAmount/3); 
    }


}