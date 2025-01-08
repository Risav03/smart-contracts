// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at risavdeb03

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IFrost {
    function mint(address to, uint256 amount) external;
}

interface INFTs {
    function ownerOf(uint256 tokenId) external returns (address);
}

struct SpecialDuration {
    uint256 startTime;
    uint256 endTime;
}

contract IceyStaking is Ownable {
    IFrost public frost;
    INFTs public nft;

    mapping(uint256 => address) public allowedContracts;
    mapping(uint256 => uint256) public emissionRate;
    mapping(uint256 => mapping(uint256 => uint256)) public stakedAt;

    mapping(uint256 => mapping(uint256 => uint256)) public specialEmissionRate;
    mapping(uint256 => uint256[]) public specialEmissionTimes;
    mapping(uint256 => mapping(uint256 => SpecialDuration)) public specialEmissionDuration;

    constructor() Ownable(msg.sender) {
        frost = IFrost(0xEd06Bb12A7BAeF7aa6572535bE7f205872B78531);
    }

    function stake(uint256 tokenId, uint256 contractId) public {
        require(allowedContracts[contractId] != address(0), "Contract not allowed");
        require(INFTs(allowedContracts[contractId]).ownerOf(tokenId) == msg.sender, "Not owner");
        stakedAt[contractId][tokenId] = block.timestamp;
    }

    function unstake(uint256 tokenId, uint256 contractId) public {
        require(stakedAt[contractId][tokenId] != 0, "Token not staked");
        claim(tokenId, contractId);
        stakedAt[contractId][tokenId] = 0;
    }

    function batchStake(uint256[] memory tokenIds, uint256 contractId) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            stake(tokenIds[i], contractId);
        }
    }

    function batchUnstake(uint256[] memory tokenIds, uint256 contractId) public {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            unstake(tokenIds[i], contractId);
        }
    }

    function claim(uint256 tokenId, uint256 contractId) public {
        require(stakedAt[contractId][tokenId] != 0, "Token not staked");
        uint256 rewards = rewardCalculation(contractId, tokenId);
        require(rewards > 0, "No rewards to claim");
        
        stakedAt[contractId][tokenId] = block.timestamp;
        frost.mint(msg.sender, rewards);
    }

    function claimAll(uint256[] memory tokenIds, uint256 contractId) public {
        uint256 totalRewards = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(stakedAt[contractId][tokenIds[i]] != 0, "Token not staked");
            totalRewards += rewardCalculation(contractId, tokenIds[i]);
            stakedAt[contractId][tokenIds[i]] = block.timestamp;
        }
        require(totalRewards > 0, "No rewards to claim");
        frost.mint(msg.sender, totalRewards);
    }

    function calculateBaseRewards(uint256 contractId, uint256 stakedTime) internal view returns (uint256) {
        uint256 elapsedTime = block.timestamp - stakedTime;
        return (elapsedTime * emissionRate[contractId]) / 86400;
    }

    function calculateSpecialRewards(
        uint256 contractId,
        uint256 stakedTime,
        uint256 startTime
    ) internal view returns (uint256) {
        SpecialDuration memory duration = specialEmissionDuration[contractId][startTime];
        
        if (block.timestamp < duration.startTime || stakedTime > duration.endTime) {
            return 0;
        }
        
        uint256 specialStart = stakedTime > duration.startTime ? stakedTime : duration.startTime;
        uint256 specialEnd = block.timestamp < duration.endTime ? block.timestamp : duration.endTime;
        
        if (specialEnd <= specialStart) {
            return 0;
        }
        
        uint256 specialDuration = specialEnd - specialStart;
        return (specialDuration * specialEmissionRate[contractId][startTime]) / 86400;
    }

    function rewardCalculation(uint256 contractId, uint256 tokenId) public view returns (uint256) {
        uint256 stakedTime = stakedAt[contractId][tokenId];
        if (stakedTime == 0) return 0;
        
        uint256 totalRewards = calculateBaseRewards(contractId, stakedTime);
        uint256[] memory specialTimes = specialEmissionTimes[contractId];
        
        for (uint256 i = 0; i < specialTimes.length; i++) {
            totalRewards += calculateSpecialRewards(contractId, stakedTime, specialTimes[i]);
        }

        return totalRewards;
    }

    function addSpecialEmission(
        uint256 contractId,
        uint256 bonus,
        uint256 startDate,
        uint256 endDate
    ) public onlyOwner {
        require(startDate < endDate, "Invalid duration");
        require(startDate > block.timestamp, "Start date must be in future");
        
        specialEmissionRate[contractId][startDate] = bonus;
        specialEmissionDuration[contractId][startDate] = SpecialDuration(startDate, endDate);
        specialEmissionTimes[contractId].push(startDate);
    }

    function setContract(uint256 index, address contractAdd, uint256 emission) public onlyOwner {
        require(contractAdd != address(0), "Invalid address");
        allowedContracts[index] = contractAdd;
        emissionRate[index] = emission;
    }

    function changeEmission(uint256 index, uint256 emission) public onlyOwner {
        require(allowedContracts[index] != address(0), "Contract not set");
        emissionRate[index] = emission;
    }

    function removeContract(uint256 index) public onlyOwner {
        require(allowedContracts[index] != address(0), "Contract not set");
        allowedContracts[index] = address(0);
        emissionRate[index] = 0;
        
        uint256[] memory times = specialEmissionTimes[index];
        for (uint256 i = 0; i < times.length; i++) {
            delete specialEmissionRate[index][times[i]];
            delete specialEmissionDuration[index][times[i]];
        }
        delete specialEmissionTimes[index];
    }
}