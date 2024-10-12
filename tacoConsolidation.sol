// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Degeneer03

pragma solidity ^0.8.20;

interface ITaco{
    function balanceOf(address owner) external view returns(uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256);
}

interface IDoodle{
    function balanceOf(address owner) external view returns(uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256);
}

interface IPixel{
    function tokensOfOwner(address owner) external view returns(uint256[] memory);
}

interface IPixelDoodle{
    function balanceOf(address owner) external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IBaby{
    function balanceOf(address owner) external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IGuacoTribe{
    function balanceOf(address owner) external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IGuacVSSour{
    function balanceOf(address owner) external view returns(uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IStaking{
    function tokenSoftStakedAt(uint256 tacoType, uint256 tokenId) external view returns (uint256);
    function softStakingRewards(uint256 tacoType, uint256 tokenId) external view returns (uint256);
}

struct returnType {
    uint256 tokenId;
    uint256 stakeType;
    uint256 unclaimed;
}

contract TacoConsolidation{

    ITaco public taco;
    IDoodle public doodle;
    IPixel public pixel;
    IPixelDoodle public pixelDoodle;
    IBaby public baby;
    IGuacoTribe public guacoTribe;
    IGuacVSSour public guacVsSour;
    IStaking public staking;

    constructor(){
        taco = ITaco(0x47faE0155F418F7355b1ca8e46589811C272a7a8);
        doodle = IDoodle(0x0c0c19675311323eBB19C44318CE00d53Ff65982);
        pixel = IPixel(0x577eFe0525c83D2Bf2f8e9EfB1e41bA3FcB84c86);
        pixelDoodle = IPixelDoodle(0x81c5a21e50F5D1e8cE0008E744285392e07Ed982);
        baby = IBaby(0xE0620C9F85a8e13F50cDA8d8306209B25D027D51);
        guacoTribe = IGuacoTribe(0xAdfcdE93709670E2fC8501A5631842A43BF7133F);
        guacVsSour = IGuacVSSour(0x4c4b675bFc5e9C5AfD3aF683366E627CB527626c);
        staking = IStaking(0x3Dc1642f53EE8546D2908ecD0D6A31e961f71E3D);
    }

    function balanceTaco(address owner) public view returns (returnType[] memory){
        uint256 size = taco.balanceOf(owner);
        returnType[] memory dataArr = new returnType[](size);

        for(uint256 i = 0; i<size; i++){
            uint256 tokenId = taco.tokenOfOwnerByIndex(owner, i);
            uint256 stakeTime = staking.tokenSoftStakedAt(0, tokenId);
            if(stakeTime>0){
                uint256 rewards = staking.softStakingRewards(0, tokenId);
                dataArr[i] = returnType(tokenId, 1, rewards);
            }
            else{
                dataArr[i] = returnType(tokenId, 0, 0);
            }
        }

        return dataArr;
    }

    function balanceDoodle(address owner) public view returns (returnType[] memory){
        uint256 size = doodle.balanceOf(owner);
        returnType[] memory dataArr = new returnType[](size);

        for(uint256 i = 0; i<size; i++){
            uint256 tokenId = doodle.tokenOfOwnerByIndex(owner, i);
            uint256 stakeTime = staking.tokenSoftStakedAt(1, tokenId);
            if(stakeTime>0){
                uint256 rewards = staking.softStakingRewards(1, tokenId);
                dataArr[i] = returnType(tokenId, 1, rewards);
            }
            else{
                dataArr[i] = returnType(tokenId, 0, 0);
            }
        }

        return dataArr;
    }

    function balancePT(address owner) public view returns (returnType[] memory){
        uint256[] memory holding = pixel.tokensOfOwner(owner);
        returnType[] memory dataArr = new returnType[](holding.length);

        for(uint256 i = 0; i<holding.length; i++){
            uint256 tokenId = holding[i];
            uint256 stakeTime = staking.tokenSoftStakedAt(3, tokenId);
            if(stakeTime>0){
                uint256 rewards = staking.softStakingRewards(3, tokenId);
                dataArr[i] = returnType(tokenId, 1, rewards);
            }
            else{
                dataArr[i] = returnType(tokenId, 0, 0);
            }
        }

        return dataArr;
    }

    function balanceDP(address owner) public view returns (returnType[] memory){
        uint256 size = pixelDoodle.balanceOf(owner);
        returnType[] memory dataArr = new returnType[](size);

        uint256 tokenId = 1;
        uint256 itemsEntered = 0;

        while(itemsEntered != size){
            if(pixelDoodle.ownerOf(tokenId) == owner){
                uint256 stakeTime = staking.tokenSoftStakedAt(4, tokenId);

                if(stakeTime>0){
                    uint256 rewards = staking.softStakingRewards(4, tokenId);
                    dataArr[itemsEntered] = returnType(tokenId, 1, rewards);
                }
                else{
                    dataArr[itemsEntered] = returnType(tokenId, 0, 0);
                }
                itemsEntered++;
            }
            tokenId++;
        }

        return dataArr;
    }

    function balanceBT(address owner) public view returns (returnType[] memory){
        uint256 size = baby.balanceOf(owner);
        returnType[] memory dataArr = new returnType[](size);

        uint256 tokenId = 1;
        uint256 itemsEntered = 0;

        while(itemsEntered != size){
            if(baby.ownerOf(tokenId) == owner){
                uint256 stakeTime = staking.tokenSoftStakedAt(5, tokenId);

                if(stakeTime>0){
                    uint256 rewards = staking.softStakingRewards(5, tokenId);
                    dataArr[itemsEntered] = returnType(tokenId, 1, rewards);
                }
                else{
                    dataArr[itemsEntered] = returnType(tokenId, 0, 0);
                }
                itemsEntered++;
            }
            tokenId++;

        }

        return dataArr;
    }

    function balanceGT(address owner) public view returns (returnType[] memory){
        uint256 size = guacoTribe.balanceOf(owner);
        returnType[] memory dataArr = new returnType[](size);

        uint256 tokenId = 1;
        uint256 itemsEntered = 0;

        while(itemsEntered != size){
            if(guacoTribe.ownerOf(tokenId) == owner){
                uint256 stakeTime = staking.tokenSoftStakedAt(6, tokenId);

                if(stakeTime>0){
                    uint256 rewards = staking.softStakingRewards(6, tokenId);
                    dataArr[itemsEntered] = returnType(tokenId, 1, rewards);
                }
                else{
                    dataArr[itemsEntered] = returnType(tokenId, 0, 0);
                }
                itemsEntered++;
            }
            tokenId++;

        }

        return dataArr;
    }

    function balanceGS(address owner) public view returns (returnType[] memory){
        uint256 size = guacVsSour.balanceOf(owner);
        returnType[] memory dataArr = new returnType[](size);

        uint256 tokenId = 1;
        uint256 itemsEntered = 0;

        while(itemsEntered != size){
            if(guacVsSour.ownerOf(tokenId) == owner){
                uint256 stakeTime = staking.tokenSoftStakedAt(7, tokenId);

                if(stakeTime>0){
                    uint256 rewards = staking.softStakingRewards(7, tokenId);
                    dataArr[itemsEntered] = returnType(tokenId, 1, rewards);
                }
                else{
                    dataArr[itemsEntered] = returnType(tokenId, 0, 0);
                }
                itemsEntered++;
            }
            tokenId++;

        }

        return dataArr;
    }


}