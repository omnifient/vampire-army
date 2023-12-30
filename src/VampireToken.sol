// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@solmate/tokens/ERC20.sol";

/// @title 🧛 $VAMP (㇏(•̀ᵥᵥ•́)ノ)
contract VampireToken is ERC20 {
    constructor(
        uint256 initialAlloc,
        address receiver
    ) ERC20("VAMPIRE", "VAMP", 18) {
        _mint(receiver, initialAlloc);
    }
}
