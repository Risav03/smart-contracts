// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

interface IPEARLTOKEN{
    function mint(address to, uint256 amount) external;
}

struct myNFTs{
    uint256 tokenId;
    uint256 rewards;
    uint256 stakeType;
}

interface IPearl {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns(uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256);
}

contract PearlStaking is ERC721Holder, Ownable{
    IPearl public pearl;
    IPEARLTOKEN public pearlToken;
    uint256 public index;
    uint256 public timeInterval;

    mapping(uint256 => address) public tokenOwnerOf;
    mapping(uint256 => uint256) public tokenHardStakedAt;
    mapping(uint256 => uint256) public tokenSoftStakedAt;

    uint256 public emissionRateHard;
    uint256 public emissionRateSoft;

    constructor(){
        pearlToken = IPEARLTOKEN(0x58243b7c159d91Ef674CAEA7B98a483AA323aA8F);
        pearl=IPearl(0x76840d45545c525be93576864288A7e2800144c7);
    }

    function setTimeInterval(uint256 time)public onlyOwner{
        timeInterval = time;
    }

    function setEmissionRateHard (uint256 amount) public onlyOwner {
        emissionRateHard = amount;
    }

    function setEmissionRateSoft(uint256 amount) public onlyOwner {
        emissionRateSoft = amount;
    }

    function stake(uint256 tokenId) external{
        pearl.safeTransferFrom(msg.sender, address(this), tokenId);
        tokenOwnerOf[tokenId] = msg.sender;
        tokenHardStakedAt[tokenId] = block.timestamp;
        delete tokenSoftStakedAt[tokenId];
    }

    function fetchMyNfts() public view returns(myNFTs[] memory){
        uint256 length = pearl.balanceOf(msg.sender);
        myNFTs[] memory dataArr = new myNFTs[](length);

        for(uint256 i = 0; i<length; i++){

            uint256 tokenId = pearl.tokenOfOwnerByIndex(msg.sender, i);
            uint256 time = tokenSoftStakedAt[tokenId];

            if(time == 0){
                uint256 rewards = 0;
                dataArr[i] = myNFTs(tokenId, rewards, 0);
            }

            else{
                uint256 rewards = softStakingRewards(tokenId);
                dataArr[i] = myNFTs(tokenId, rewards, 1);
            }


        }
            return dataArr;

    }

    function stakeAll(uint256[] memory tokenId) external{
        for(uint256 i = 0; i<tokenId.length; i++){
            pearl.safeTransferFrom(msg.sender, address(this), tokenId[i]);
            tokenOwnerOf[tokenId[i]] = msg.sender;
            tokenHardStakedAt[tokenId[i]] = block.timestamp;
            delete tokenSoftStakedAt[tokenId[i]];
        }
        
    }

    function softStake(uint256 tokenId) external{
        tokenSoftStakedAt[tokenId] = block.timestamp;
    }

    function softStakeAll(uint256[] memory tokenId) external{
        for(uint256 i = 0; i<tokenId.length; i++){
            tokenSoftStakedAt[tokenId[i]] = block.timestamp;
        }
    }


    function softStakingRewards(uint256 tokenId) public view returns(uint256){

        if(tokenSoftStakedAt[tokenId] != 0){
            uint256 timeElapsed = (block.timestamp - tokenSoftStakedAt[tokenId])/timeInterval;
            uint256 rewards = emissionRateSoft * timeElapsed ;
            return rewards;
        }
        else{
            return 0;
        }
    }

    function hardStakingRewards(uint256 tokenId) public view returns(uint256){
        if(tokenOwnerOf[tokenId] == msg.sender){
            uint256 timeElapsed = (block.timestamp - tokenHardStakedAt[tokenId])/timeInterval;
            uint256 rewards = emissionRateHard * timeElapsed ;
            return rewards;
        }
        else{
            return 0;
        }
    }

    function claim(uint256 tokenId) external {
    
        if(hardStakingRewards(tokenId) != 0){
            require(msg.sender == tokenOwnerOf[tokenId]);
            pearlToken.mint(msg.sender, hardStakingRewards(tokenId));
            delete tokenHardStakedAt[tokenId];
            tokenHardStakedAt[tokenId] = block.timestamp;
        }
        else{
            pearlToken.mint(msg.sender, softStakingRewards(tokenId));
            delete tokenSoftStakedAt[tokenId];
            tokenSoftStakedAt[tokenId] = block.timestamp;
        }
        
    }

    function claimAll(uint256[] memory tokenId) external {
        for(uint256 i = 0; i<tokenId.length; i++){
            
        if(hardStakingRewards(tokenId[i]) != 0){
            require(msg.sender == tokenOwnerOf[tokenId[i]]);
            pearlToken.mint(msg.sender, hardStakingRewards(tokenId[i]));
            delete tokenHardStakedAt[tokenId[i]];
            tokenHardStakedAt[tokenId[i]] = block.timestamp;
        }

        else{
            pearlToken.mint(msg.sender, softStakingRewards(tokenId[i]));
            delete tokenSoftStakedAt[tokenId[i]];
            tokenSoftStakedAt[tokenId[i]] = block.timestamp;
        }
        }
        
    }

    function unstake(uint256 tokenId) external{
        require(tokenOwnerOf[tokenId]== msg.sender, "You're not the owner");
        pearl.safeTransferFrom(address(this), msg.sender, tokenId);
        delete tokenOwnerOf[tokenId];
        delete tokenHardStakedAt[tokenId];
        tokenSoftStakedAt[tokenId] = block.timestamp;
    }

    function unstakeAll(uint256[] memory tokenId) external{
        for(uint256 i = 0; i<tokenId.length; i++){
            require(tokenOwnerOf[tokenId[i]]== msg.sender, "You're not the owner");
            pearl.safeTransferFrom(address(this), msg.sender, tokenId[i]);
            delete tokenOwnerOf[tokenId[i]];
            delete tokenHardStakedAt[tokenId[i]];
            tokenSoftStakedAt[tokenId[i]] = block.timestamp;
        }
    }

}