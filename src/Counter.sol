// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @title Counter
/// @notice A minimal example contract — replace with your protocol
/// implementation
contract Counter {
    /// @notice The current counter value
    /// @return The current counter value
    uint256 public number;

    /// @notice Sets the counter to a specific value
    /// @param newNumber The value to assign
    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    /// @notice Increments the counter by one
    function increment() public {
        ++number;
    }
}
