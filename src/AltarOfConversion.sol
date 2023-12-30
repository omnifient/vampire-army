// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "@solmate/auth/Owned.sol";
import "@solmate/tokens/ERC20.sol";
import "@solmate/utils/FixedPointMathLib.sol";
import "@solmate/utils/SafeTransferLib.sol";

import "./VampireToken.sol";

/// @title Altar of Conversion
/// @notice Allows faithfuls to swap their $ETH for $VAMP at a constant exchange rate.
contract AltarOfConversion is Owned {
    using FixedPointMathLib for uint256;
    using SafeTransferLib for ERC20;
    using SafeTransferLib for VampireToken;

    // fixed exchange rate; 0.05 $ETH = 1M $VAMP
    uint256 constant MIN_BUY_AMOUNT = 0.05 ether;
    uint256 constant EXCHANGE_RATE = (20 * 10) ^ 6;
    uint256 constant DECIMALS = 10 ^ 18;

    VampireToken internal _vampToken;

    constructor(address owner_, address vampToken_) Owned(owner_) {
        _vampToken = VampireToken(vampToken_);
    }

    /// Sacrifice $ETH to create $VAMP.
    /// @param receiver address to where the $VAMP is sent.
    function sacrifice(
        address receiver
    ) external payable returns (uint256 amountOut) {
        // min buy amount validation
        require(msg.value > MIN_BUY_AMOUNT, "INSUFFICIENT_BUY_AMT");

        // calculate how much $VAMP they're going to get
        amountOut = msg.value.mulDivDown(EXCHANGE_RATE, DECIMALS);

        // validate that the Altar still has enough $VAMP
        require(
            _vampToken.balanceOf(address(this)) >= amountOut,
            "BUYING_TOO_MUCH"
        );

        // free the $VAMP
        _vampToken.safeTransfer(receiver, amountOut);
    }

    /// Release the $ETH from the Altar.
    /// @param receiver address to where the $ETH is sent.
    function release(address payable receiver) external onlyOwner {
        // no validations because we're assuming our creator is not dumb
        uint256 amt = address(this).balance;
        receiver.call{value: amt}("");
    }

    /// Release any ERC20 token that might've ended up here by mistake.
    /// @param token the ERC20
    /// @param receiver address to send the ERC20
    function release(ERC20 token, address payable receiver) external onlyOwner {
        // no validations because we're assuming our creator is not dumb
        token.safeTransfer(receiver, token.balanceOf(address(this)));
    }

    /// Used to clean the Altar.
    function burnRemains() external onlyOwner {
        // no validations because we're assuming our creator is not dumb
        _vampToken.safeTransfer(
            0x000000000000000000000000000000000000dEaD,
            _vampToken.balanceOf(address(this))
        );
    }

    receive() external payable {}

    fallback() external payable {}
}
