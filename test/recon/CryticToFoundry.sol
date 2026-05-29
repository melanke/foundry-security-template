// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {TargetFunctions} from "./TargetFunctions.sol";
import {Test} from "forge-std/Test.sol";

// Entry point for Medusa, Echidna, and forge invariant testing.
// - Medusa/Echidna: deploy this contract and call target functions
// - forge: run as `forge test --match-contract CryticToFoundry`
//   (uses Foundry's invariant runner against the same properties)
contract CryticToFoundry is TargetFunctions, Test {
    // Constructor runs for Medusa and Echidna (they don't call setUp).
    constructor() {
        _deploy();
    }

    // setUp runs for Foundry invariant tests (re-deploys cleanly before each
    // run).
    function setUp() public {
        _deploy();
        targetContract(address(this));
    }

    // Bridge: Foundry invariant runner calls this; it delegates to property_
    // functions. Add one assert() per property_ function defined in
    // Properties.sol. Generated stubs from the defi-spec-driven skill will be
    // wired here during
    // project setup.
    function invariant_properties() public pure {
        assert(property_example_stub());
    }
}
