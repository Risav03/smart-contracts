// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ISimply{
    function ownerOf(uint256 tokenId) external view returns(address);  
    function balanceOf(address owner) external view returns (uint256);
}

contract SimplyInfo {

    ISimply public simply;

    constructor(){
        simply = ISimply(0x1a90102b680807CE176bE575479e4b824fD1F392);
    }

    // uint256[] arr = [229, 230, 178, 188, 225, 267, 189, 286, 249, 218, 192, 251, 274, 257, 292, 10480, 276, 300, 285, 628, 310, 1870, 4300, 5716, 4302, 4303, 4305, 1871, 4306, 1872, 4307, 1889, 4304, 24, 1888, 490, 491, 492, 1887, 1886, 1885, 1884, 1883, 1882, 1881, 1880, 1879, 5717, 1878, 10332, 1877, 1876, 1875, 1874, 1873, 316, 405, 1019, 1512, 1515, 1510, 1516, 1072, 1548, 1518, 1517, 1519, 1520, 1521, 1523, 1524, 1525, 1526];

    function tokenOfOwner(uint multiplier) public view returns(uint256[] memory){
        uint256 length = simply.balanceOf(msg.sender);

        uint256[] memory owned = new uint256[](length);
        uint256 j = 0;
        for(uint256 i = 400*multiplier; i<400*(multiplier+1); i++){
            try simply.ownerOf(i) returns (address){
                if(simply.ownerOf(i) == msg.sender){
                    owned[j] = i;
                    j++;
                }
            }
            catch{
                continue;
            }
            
        }

        return owned;
    }
}