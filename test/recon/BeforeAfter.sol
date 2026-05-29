// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Setup} from "./Setup.sol";

// Captures a snapshot of relevant state before and after each call.
// Add fields for every protocol variable that invariants will reason about.
abstract contract BeforeAfter is Setup {
    struct Vars {
        uint256 counter_number;
    }

    Vars internal _before;
    Vars internal _after;

    function __before() internal {
        _before.counter_number = counter.number();
    }

    function __after() internal {
        _after.counter_number = counter.number();
    }
}
