// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@solmate/tokens/ERC20.sol";
import "@solmate/utils/FixedPointMathLib.sol";

import "./VampireToken.sol";

/// @title
/// @author
/// @notice
abstract contract Graveyard {
    using FixedPointMathLib for uint256;

    // 1 graveyard contract deployed per target token
    VampireToken internal _vampireToken;
    ERC20 internal _targetToken;

    uint256 internal _vampireDecimals;
    uint256 internal _targetDecimals;

    // TODO: oracle or whatever

    constructor(
        address vampireToken,
        address targetToken,
        uint256 vampireDecimals,
        uint256 targetDecimals
    ) {
        _vampireToken = VampireToken(vampireToken);
        _targetToken = ERC20(targetToken);

        _vampireDecimals = vampireDecimals;
        _targetDecimals = targetDecimals;
    }

    function convertToVampire(uint256 numBodies, address receiver) external {
        // transfer the $TOKENs here
        _targetToken.transferFrom(msg.sender, address(this), numBodies);

        // compute how many $VAMPs to mint
        uint256 rate = _getExchangeRate();
        uint256 mintAmount = numBodies.mulDivDown(rate, _targetDecimals);

        // mint to receiver
        _vampireToken.mint(receiver, mintAmount);

        // TODO: do stuff with the received token
    }

    function _getExchangeRate() internal virtual returns (uint256);
}
