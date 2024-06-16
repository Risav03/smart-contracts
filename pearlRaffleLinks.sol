// SPDX-License-Identifier: MIT
// Made by 3xBuilds (https://linktr.ee/3xbuilds)
// Reach out on Discord at Needle#5483 or on X(Twitter) at Risavdeb03

pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PearlRaffleLinks is Ownable{
    mapping(uint256 => string) public assignedLinks;

    function setLink (string memory link, uint256 index) public onlyOwner{
        assignedLinks[index] = link;
    }
}