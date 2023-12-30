// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@solmate/tokens/ERC20.sol";
import "@solmate/utils/FixedPointMathLib.sol";
import "@solmate/utils/SafeTransferLib.sol";

import "./VampireToken.sol";

/// @title Template for all the $VAMP Graveyards.
/// @notice WIP
abstract contract Graveyard {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;

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
        _targetToken.safeTransferFrom(msg.sender, address(this), numBodies);

        // compute how many $VAMPs to mint
        uint256 rate = _getExchangeRate();
        uint256 mintAmount = numBodies.mulDivDown(rate, _targetDecimals);

        // TODO: mint to receiver

        // TODO: do stuff with the received token
    }

    function _getExchangeRate() internal virtual returns (uint256);
}
