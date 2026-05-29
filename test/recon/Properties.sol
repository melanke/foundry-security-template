// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {BeforeAfter} from "./BeforeAfter.sol";

// Protocol invariants. Each property_ function must return true at all times.
// Medusa and Echidna will flag any execution sequence that returns false.
//
// Naming convention: property_{invariant_slug_underscored}
//   INV-vault-solvency   →  property_vault_solvency()
//   INV-share-monotonic  →  property_share_monotonic()
//
// Every invariant in .specs/economics/INVARIANTS.md (or INVARIANTS.md if
// you are not using the defi-spec-driven workflow) must have a corresponding
// function here. The slug in the function name is the link between the spec
// and the running fuzzer — keep them in sync.
//
// Stubs are generated during project setup from the spec invariants.
// Replace `return true;` with the actual property check for each one.
abstract contract Properties is BeforeAfter {
    // TODO: replace this example with your protocol invariants.
    // Each stub is generated from an INV-* entry in
    // .specs/economics/INVARIANTS.md. Example stub — delete when real
    // invariants are added:
    function property_example_stub() public pure returns (bool) {
        return true;
    }
}
