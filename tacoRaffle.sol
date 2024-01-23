// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


abstract contract Ownable is Context {
    address private _owner;


    error OwnableUnauthorizedAccount(address account);


    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }


    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IGUAC{
    function transferFrom(address from, address to, uint256 amount) external;
}

interface INft{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

abstract contract TacoRaffle is Ownable{

    IGUAC public guacToken;
    INft public nftToTransfer;

    mapping(uint => uint256) public ticketLimit;
    mapping(uint => uint256) public ticketLimitPerWallet;
    mapping(uint => uint256) public ticketsSold;
    mapping(uint => uint256) public raffleTokenId;
    mapping(uint => address) public raffleContract;
    mapping(uint => mapping(address => uint256)) public walletHolding;
    mapping(uint => mapping(uint => address)) public enteredWallet;
    mapping(uint => uint256) public raffleEntryCost;
    mapping(uint256 => address) public winningAddress;
    mapping(uint => uint) public totalEntrants;

    uint randNonce = 0;

    constructor(){
        guacToken = IGUAC(0x6FE947Ffd91aE3A7C8a6090B692cA2BDeCD30269);
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
        guacToken.transferFrom(msg.sender, 0xf07F26f6500b72FefcE1243AC75fC77E9C477a9D, cost);
    }

    function chooseWinner(uint256 raffleIndex) public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % totalEntrants[raffleIndex];
    }

    function declareWinner(uint256 raffleIndex) public onlyOwner{
        randNonce++;
        uint256 winningIndex = chooseWinner(raffleIndex);
        address winningWallet = enteredWallet[raffleIndex][winningIndex];

        winningAddress[raffleIndex] = winningWallet;
        
        nftToTransfer = INft(raffleContract[raffleIndex]);
        nftToTransfer.safeTransferFrom(msg.sender, winningWallet, raffleTokenId[raffleIndex]);
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
        delete winningAddress[raffleIndex];
        delete totalEntrants[raffleIndex];
    }



}