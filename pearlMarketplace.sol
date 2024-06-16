// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

struct returnData {
    address contractAddress;
    uint256 tokenId;
    address owner;
    uint256 itemPrice;
} 

interface IPearl{
    function transferFrom(address from, address to, uint256 amount) external;
}

interface INft{
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns(address);
}

contract PearlMarketplace is Ownable{

   IPearl public pearlToken;
    INft public nftToTransfer;

    mapping(uint => address) public minimartItemContract;
    mapping(uint => uint256) public minimartItemTokenId;

    mapping(uint => address) public approvedCollection;

    mapping(uint => uint256) public minimartItemPrice;


    uint256 public num = 1;
    uint256 public totalListed;


     constructor(){
        pearlToken = IPearl(0x58243b7c159d91Ef674CAEA7B98a483AA323aA8F);
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

    function setMinimartItem(address contractAddress, uint256 tokenId, uint256 price) public onlyOwner {
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
        pearlToken.transferFrom(msg.sender, nftToTransfer.ownerOf(minimartItemTokenId[index]), minimartItemPrice[index]);

        nftToTransfer.safeTransferFrom(nftToTransfer.ownerOf(minimartItemTokenId[index]), msg.sender, minimartItemTokenId[index]);

        delete minimartItemContract[index];
        delete minimartItemTokenId[index];
        delete minimartItemPrice[index];

    }

    function unListItem(uint index) public onlyOwner{
        nftToTransfer = INft(minimartItemContract[index]);

        require(nftToTransfer.ownerOf(minimartItemTokenId[index]) == msg.sender, "Not the Owner");
        delete minimartItemContract[index];
        delete minimartItemTokenId[index];
        delete minimartItemPrice[index];

    }

}