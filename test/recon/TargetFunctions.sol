// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Properties} from "./Properties.sol";

// Wrappers around every public function the fuzzer is allowed to call.
// The fuzzer will sequence arbitrary combinations of these with random inputs.
// __before/__after bookend each call to enable before/after property checks.
abstract contract TargetFunctions is Properties {
    function counter_setNumber(uint256 newNumber) public {
        __before();
        counter.setNumber(newNumber);
        __after();
    }

    function counter_increment() public {
        __before();
        counter.increment();
        __after();
    }
}
