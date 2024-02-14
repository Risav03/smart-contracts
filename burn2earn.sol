// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

    constructor() {
       
        _transferOwnership(msg.sender);
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

interface IToken{
    function transferFrom(address from, address to, uint256 amount) external;
    function mint(address to, uint256 amount) external;
}

struct NFTArr {
    string tokenUri;
    uint256 tokenId;
}

interface SimplyNFT{
    function burn(uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns(address);
    function tokenURI(uint256 tokenId) external view returns(string memory);
    function balanceOf(address owner) external view returns (uint256);
}

contract BurntoEarn is Ownable{
    SimplyNFT public simply;
    IToken public token;

    constructor(){
        simply = SimplyNFT(0x1a90102b680807CE176bE575479e4b824fD1F392);
        token = IToken(0x628a73c527f1c191F27C4d466238381109B6eAFC);
    }

    uint[] public burntTokens = [229, 230, 178, 188, 225];

    uint256 rewardAmount;
    address caller;


    function checkBurnt(uint index) public view returns(bool) {
        bool exists = false;
        for(uint i = 0; i< burntTokens.length; i++){
            if(burntTokens[i] == index){
                exists = true;
            }
        } 
        return exists;
    }


    function fetchTokenURI()public view returns(NFTArr[] memory){

        uint256 length = simply.balanceOf(msg.sender);
        NFTArr[] memory dataArr = new NFTArr[](length);
        uint j = 0;

        for(uint i = 0; i<16000; i++){
            bool exists = checkBurnt(i);
            if(exists == false && simply.ownerOf(i) == msg.sender){
                dataArr[j] = NFTArr(simply.tokenURI(i), i);
                j++;
            }
           
            
        }

        return dataArr;
    }

    function setRewardAmount(uint256 newAmount)public onlyOwner{
        rewardAmount = newAmount;
    }

    function setBurnToEarnCaller(address contractAddress) public onlyOwner{
        caller = contractAddress;
    }

    function burnToEarn(uint256 tokenId, uint256 additional, address owner) public {
        require(msg.sender == caller, "Not allowed to call directly");
        simply.burn(tokenId);
        burntTokens.push(tokenId);
        token.mint(owner, rewardAmount+additional);
    }


}