// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";

// Delete this file during project setup.
// project-setup.md generates the real unit test file(s) from
// .specs/tests/UNIT-TESTS.md — one file per contract under test,
// named [ContractName]Test.t.sol.
//
// Each function maps to one UNIT-TESTS.md scenario and references its REQ-*
// slug.
contract ExampleTest is Test {
    // TODO: import and deploy your contract under test

    function setUp() public {
        // TODO: deploy contract
    }

    /// @dev Given: [precondition]. When: [action]. Then: [expected outcome].
    // REQ-example-slug
    function test_Given_someState_When_someAction_Then_someOutcome() public {
        // TODO: implement from UNIT-TESTS.md scenario
    }

    /// @dev Given: [precondition]. When: [action]. Then: reverts with [error].
    // REQ-example-slug
    function test_Given_someState_When_someAction_Then_revertsWithError()
        public {
        // TODO: implement revert scenario from UNIT-TESTS.md
    }
}
