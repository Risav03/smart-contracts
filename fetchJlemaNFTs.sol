// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

pragma solidity ^0.8.22;

interface IJlema{
    function ownerOf(uint256 tokenId) external view returns(address);  
    function balanceOf(address owner) external view returns (uint256);
}


contract jlemaFetcher {

    IJlema public jlema;
    
    constructor(){
        jlema = IJlema(0x71D9943cb18d9Cb3605bc63Dc6Ce659eB7a78ced);
    }

    function tokenOfOwnerJlema(uint multiplier, address owner) public view returns(uint256[] memory){
        uint256 length = jlema.balanceOf(owner);

        uint256[] memory owned = new uint256[](length);
        uint256 j = 0;
        for(uint256 i = 1111*multiplier; i<1111*(multiplier+1); i++){
            try jlema.ownerOf(i) returns (address){
                if(jlema.ownerOf(i) == owner){
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