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
    using SafeTransferLib for VampireToken;

    // 1 graveyard contract deployed per target token
    VampireToken internal _vampireToken;
    ERC20 internal _targetToken;

    // decimals for exchange rate
    uint256 internal _vampireDecimals;
    uint256 internal _targetDecimals;

    // aka treasury
    address internal _dracula;

    constructor(
        address vampireToken,
        address targetToken,
        uint256 vampireDecimals,
        uint256 targetDecimals,
        address dracula
    ) {
        _vampireToken = VampireToken(vampireToken);
        _targetToken = ERC20(targetToken);

        _vampireDecimals = vampireDecimals;
        _targetDecimals = targetDecimals;

        _dracula = dracula;
    }

    function convertToVampire(address receiver, uint256 numBodies) external {
        // transfer the $TOKENs here
        _targetToken.safeTransferFrom(msg.sender, address(this), numBodies);

        // compute how many $VAMPs to mint
        uint256 amount = numBodies.mulDivDown(
            _getExchangeRate(),
            _targetDecimals
        );

        // transfer $VAMP to receiver
        require(_vampireToken.balanceOf(address(this)) >= amount, "NOT_ENOUGH");
        _vampireToken.safeTransfer(receiver, amount);

        // do stuff with the received token, for example:
        // - swap 100% of $TOKEN for $ETH
        // - buy $VAMP with X% $ETH, then burn $VAMP
        // - add LP with Y% $ETH
        // - send Z% $ETH to Dracula
        _postConvert(numBodies);
    }

    function _getExchangeRate() internal virtual returns (uint256);

    function _postConvert(uint256 amt) internal virtual;
}
