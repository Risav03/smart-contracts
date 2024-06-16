// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Simple is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit {
    constructor()
        ERC20("Simple", "SIMPLE")
        ERC20Permit("Simple")
    {}

    mapping(address => bool) public controllers;

    function setController(address controller)public onlyOwner{
        controllers[controller] = true;
    }

    function removeController(address controller) public onlyOwner{
        controllers[controller] = false;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public {

        require(controllers[msg.sender] == true , "Not a controller");
        _mint(to, amount);
    }


    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
