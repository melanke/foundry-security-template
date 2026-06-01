// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";

// Delete this file during project setup.
// project-setup.md generates the real integration test file from
// .specs/tests/SCENARIOS.md — one file covering cross-contract flows
// and documented attack scenarios.
//
// Every integration test uses at least three distinct addresses and
// crosses at least one contract boundary. Place single-contract
// tests in test/unit/ instead.
contract ExampleIntegrationTest is Test {
    // TODO: import and deploy the full contract system

    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal carol = makeAddr("carol");

    function setUp() public {
        // TODO: deploy full contract system
    }

    /// @dev Full happy-path flow from deployment to final user action.
    // Scenario: [name from SCENARIOS.md]
    function test_Given_deployedSystem_When_fullFlow_Then_invariantsHold()
        public {
        // TODO: implement from SCENARIOS.md
    }
}
