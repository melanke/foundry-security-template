// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    /// @dev Given: counter is at zero. When: increment called. Then: number is
    /// 1.
    function test_Given_counter0_When_increment_Then_number1() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    /// @dev Given: any value x. When: setNumber(x) called. Then: number equals
    /// x.
    function testFuzz_Given_anyValue_When_setNumber_Then_numberMatchesInput(uint256 x)
        public
    {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
