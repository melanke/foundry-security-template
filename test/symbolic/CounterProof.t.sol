// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../../src/Counter.sol";

// Halmos symbolic proof tests. Run with: halmos --match-contract
// CounterProofTest
// Functions prefixed check_ are treated as formal proofs: Halmos uses symbolic
// execution to find any input that violates the assertion, or proves none
// exists. Unlike fuzz tests (probabilistic), a passing check_ is a *proof* over
// all inputs.
//
// Constraints:
//   vm.assume(...)    — restrict the symbolic input space
//   --loop N          — bound loop unrolling (default: 2)
//   Unbounded loops and external calls to unknown contracts are not provable.
contract CounterProofTest is Test {
    Counter internal counter;

    function setUp() public {
        counter = new Counter();
    }

    /// @dev Prove: forall x, setNumber(x) results in number == x
    function check_setNumber(uint256 x) public {
        counter.setNumber(x);
        assert(counter.number() == x);
    }

    /// @dev Prove: forall initial < max, increment increases number by exactly
    /// 1
    function check_increment(uint256 initial) public {
        vm.assume(initial < type(uint256).max);
        counter.setNumber(initial);
        counter.increment();
        assert(counter.number() == initial + 1);
    }

    /// @dev Prove: setNumber then increment is equivalent to setNumber(x+1)
    function check_setThenIncrement(uint256 x) public {
        vm.assume(x < type(uint256).max);
        counter.setNumber(x);
        counter.increment();
        assert(counter.number() == x + 1);
    }
}
