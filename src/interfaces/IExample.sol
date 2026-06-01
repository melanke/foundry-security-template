// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// Delete this file during project setup.
// project-setup.md generates the real interface file(s) from
// .specs/interface/FUNCTIONS.md and .specs/interface/EVENTS.md —
// one file per contract, named I[ContractName].sol.
//
// All NatSpec (@notice, @param, @return), custom errors, and events
// live in the interface. The implementation contract uses
// /// @inheritdoc I[ContractName] and never duplicates NatSpec.

/// @title IExample
/// @notice Replace with your protocol's interface
interface IExample {
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    /// @notice Emitted when [something happens]
    /// @param caller The address that triggered the action
    /// @param value The value involved
    event ExampleEvent(address indexed caller, uint256 value);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    /// @notice Reverts when [condition]
    error ExampleError();

    // -------------------------------------------------------------------------
    // Functions
    // -------------------------------------------------------------------------

    /// @notice Does something useful
    /// @param value_ The input value
    /// @return result The output value
    function exampleFunction(uint256 value_) external returns (uint256 result);
}
