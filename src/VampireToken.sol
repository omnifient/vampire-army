// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@solmate/auth/Owned.sol";
import "@solmate/tokens/ERC20.sol";

contract VampireToken is ERC20, Owned {
    mapping(address => bool) public minters;

    constructor(
        address owner_,
        address initialAllocReceiver,
        uint256 initialAllocation
    ) ERC20("VAMPIRE", "VAMP", 18) Owned(owner_) {
        _mint(initialAllocReceiver, initialAllocation);
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "NOT_MINTER");

        _;
    }

    function addMinter(address newMinter) external onlyOwner {
        minters[newMinter] = true;
    }

    function delMinter(address minter) external onlyOwner {
        delete minters[minter];
    }

    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }
}
