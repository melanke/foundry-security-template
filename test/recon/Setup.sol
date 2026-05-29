// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Counter} from "../../src/Counter.sol";

// Deploy and configure all contracts under test.
// Replace Counter with your protocol contracts and add constructor args.
abstract contract Setup {
    Counter internal counter;

    function _deploy() internal {
        counter = new Counter();
    }
}
