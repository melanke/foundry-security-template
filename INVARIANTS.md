# Protocol Invariants

This file enumerates the invariants that must hold across all protocol states.
Maintain it as a living document alongside the contracts — an invariant that is
no longer enforced by the code should be removed or marked as deprecated here.

An auditor reading this file should be able to derive the full set of behavioral
guarantees the protocol claims to maintain.

---

## Format

Each invariant should include:

- **ID**: a stable identifier (e.g., `INV-001`) used in test comments and audit reports
- **Statement**: a single sentence stating what must always be true
- **Scope**: which contracts or subsystems this applies to
- **Enforcement**: how it's tested (invariant test, fuzz test, formal verification, review-only)

---

## Invariants

<!-- Example:
### INV-001 — Solvency

**Statement:** The sum of all user balances never exceeds the protocol's total token holdings.
**Scope:** `Vault.sol`
**Enforcement:** `test/invariant/VaultInvariant.t.sol` — `invariant_solvency`
-->
