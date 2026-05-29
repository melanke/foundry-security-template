// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {BeforeAfter} from "./BeforeAfter.sol";

// Protocol invariants. Each property_ function must return true at all times.
// Medusa and Echidna will flag any execution sequence that returns false.
//
// Add your invariants here. See INVARIANTS.md for the full list and their
// rationale. Every invariant in that file should have a corresponding property_
// function here.
abstract contract Properties is BeforeAfter {
    // Example: once set, the counter number can only change via explicit calls.
    // (This is trivially true for Counter — replace with real protocol
    // invariants.)
    function property_numberChangesOnlyViaExplicitCall()
        public
        pure
        returns (bool)
    {
        return true;
    }
}
