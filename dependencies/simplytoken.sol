// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./ERC20Pausable.sol";
import "./Ownable.sol";
import "./ERC20Permit.sol";

contract Simply is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit {
    constructor()
        ERC20("Simply", "SIMPLY")
        ERC20Permit("Simply")
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
