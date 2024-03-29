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

struct returnData {
    address contractAddress;
    uint256 tokenId;
    address owner;
    uint256 itemPrice;
} 

interface IGUAC{
    function transferFrom(address from, address to, uint256 amount) external;
}

interface INft{
   function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns(address);
}

abstract contract MiniMart is Ownable{

    IGUAC public guacToken;
    INft public nftToTransfer;

    mapping(uint => address) public minimartItemContract;
    mapping(uint => uint256) public minimartItemTokenId;

    mapping(uint => address) public approvedCollection;

    mapping(uint => uint256) public minimartItemPrice;


    uint256 public num = 1;
    uint256 public totalListed;


     constructor(){
        guacToken = IGUAC(0x6FE947Ffd91aE3A7C8a6090B692cA2BDeCD30269);
    }

    function fetchData() public view returns (returnData[] memory){

        returnData[] memory dataArr = new returnData[](totalListed);

        for(uint256 index = 0; index<totalListed; index++){

            if(minimartItemContract[index] != address(0)){
                dataArr[index] = returnData(minimartItemContract[index], minimartItemTokenId[index], INft(minimartItemContract[index]).ownerOf(minimartItemTokenId[index]), minimartItemPrice[index]);
            }
        }
        return dataArr;
    }

    function returnApprovedContracts() public view returns(address[] memory) {
        address[] memory addArr = new address[](num);
        for(uint i = 0; i <num-1; i++){
            addArr[i] = approvedCollection[i];
        }
        return addArr;
    }

    function setApprovedCollection(address collection) public onlyOwner{
        for(uint256 i = 0; i<=num; i++){
            if(approvedCollection[i] == address(0)){
               approvedCollection[i] = collection;
                num++;   
               break;
            }
        }
    }

    function removeApprovedCollection(uint index) public onlyOwner{
        delete approvedCollection[index];
    }

    function setMinimartItem(address contractAddress, uint256 tokenId, uint256 price) public {
        bool inside = false;

        for(uint256 i = 0; i<totalListed; i++){
            if(minimartItemContract[i] == address(0)){
                minimartItemContract[i] = contractAddress;
                minimartItemTokenId[i] = tokenId;
                minimartItemPrice[i] = price;
                inside = true;
                break;
            }
            
        }

        if(!inside){
            minimartItemContract[totalListed] = contractAddress;
            minimartItemTokenId[totalListed] = tokenId;
            minimartItemPrice[totalListed] = price;
            totalListed++;
        }

    }

    function buyMinimartItem(uint256 cost, uint256 index) public{
        nftToTransfer = INft(minimartItemContract[index]);
        require(cost == minimartItemPrice[index], "Low amount");
        guacToken.transferFrom(msg.sender, nftToTransfer.ownerOf(minimartItemTokenId[index]), minimartItemPrice[index]);

        nftToTransfer.safeTransferFrom(nftToTransfer.ownerOf(minimartItemTokenId[index]), msg.sender, minimartItemTokenId[index]);

        delete minimartItemContract[index];
        delete minimartItemTokenId[index];
        delete minimartItemPrice[index];

    }

    function unListItem(uint index) public{
        nftToTransfer = INft(minimartItemContract[index]);

        require(nftToTransfer.ownerOf(minimartItemTokenId[index]) == msg.sender, "Not the Owner");
        delete minimartItemContract[index];
        delete minimartItemTokenId[index];
        delete minimartItemPrice[index];

    }


}