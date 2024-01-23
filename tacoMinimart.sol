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

abstract contract MiniMart is Ownable{

    IGUAC public guacToken;
    INft public nftToTransfer;

    mapping(uint => address) minimartItemContract;
    mapping(uint => uint256) minimartItemTokenId;

    mapping(uint => address) indexOwner;
    mapping(uint => address) approvedCollection;

    mapping(uint => uint256) minimartItemPrice;

    uint256 minimartIndex;

     constructor(){
        guacToken = IGUAC(0x6FE947Ffd91aE3A7C8a6090B692cA2BDeCD30269);
    }

    function setApprovedCollection(address collection, uint num) public onlyOwner{
        approvedCollection[num] = collection;
    }

    function removeApprovedCollection(uint num) public onlyOwner{
        delete approvedCollection[num];
    }

    function setMinimartItem(address contractAddress, uint256 tokenId, uint256 price) public {
        minimartItemContract[minimartIndex] = contractAddress;
        minimartItemTokenId[minimartIndex] = tokenId;
        minimartItemPrice[minimartIndex] = price;

        indexOwner[minimartIndex] = msg.sender;

        while(minimartItemContract[minimartIndex] != address(0)){
            minimartIndex++;
        }
    }

    function buyMinimartItem(uint256 cost, uint256 index) public{
        require(cost == minimartItemPrice[index], "Low amount");
        guacToken.transferFrom(msg.sender, indexOwner[index], minimartItemPrice[index]);

        nftToTransfer = INft(minimartItemContract[index]);
        nftToTransfer.safeTransferFrom(indexOwner[index], msg.sender, minimartItemTokenId[index]);

        delete minimartItemContract[index];
        delete minimartItemTokenId[index];
        delete minimartItemPrice[index];

        minimartIndex = index;
    }

    function unListItem(uint256 index) public{
        require(msg.sender == indexOwner[index], "Not the Owner");
        delete minimartItemContract[index];
        delete minimartItemTokenId[index];
        delete minimartItemPrice[index];
        minimartIndex = index;
    }


}