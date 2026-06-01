# Agent Development Guide

Instructions for AI coding agents working in this repository.
Keep this file updated when the toolchain or conventions change.

---

## Build and validation

### During implementation

Use `forge build` to validate changes as you work. For large projects, scope first
to get faster feedback — build only the contract you modified before running a full
build:

```bash
forge build src/Vault.sol       # single contract, fastest feedback
forge build src/               # all src/ contracts, skip tests
forge build                    # full build including tests — do this before committing
```

Start scoped, expand when the scoped build is clean.

### Before committing

Run the full validation cycle in this order — order matters:

```bash
forge fmt                      # auto-fix formatting first
npx lintspec src/              # NatSpec completeness — may add code, must come before build
forge build --sizes            # full build + check contract sizes (24kB EIP-170 limit)
slither src/                   # static analysis
```

Fix every issue from each step. Then **repeat the full cycle from `forge fmt`** — 
fixes to lint or NatSpec often introduce formatting differences that `forge fmt` 
will reformat, which can silently discard manually added inline comments (including
Slither suppressions). The cycle is complete only when `forge fmt --check` passes
with no diff after all other fixes are applied.

### Fixing issues

**`forge fmt` differences**: always run `forge fmt` (no flags) to auto-fix. Never
manually reformat code — let the tool own formatting.

**`forge build` warnings**: zero warnings is the policy. Fix the root cause; do not
suppress without a documented reason.

**`lintspec` failures**: add missing `@notice`, `@param`, `@return` tags to the
flagged function. Every public and external function, event, error, and struct
requires NatSpec.

**Slither findings**:
- Actionable: fix the root cause before suppressing anything.
- False positive or accepted risk: add an entry to `KNOWN_ISSUES.md`, then suppress
  inline. The suppression and the `KNOWN_ISSUES.md` entry must be added together.

```solidity
// Reason: CEI pattern enforced and nonReentrant guard active — see KNOWN_ISSUES.md §vault-reentrancy
// slither-disable-next-line reentrancy-no-eth
```

### Foundry configuration

Set these in `foundry.toml` at project start — retrofitting is noisy:

```toml
[fmt]
line_length = 80
int_types = "long"              # uint256, not uint
number_underscore = "thousands" # 1_000_000, not 1000000
```

Commit `foundry.lock`. It pins library dependency versions for reproducible builds.
Update intentionally with `forge update`, never silently.

---

## Testing

### Prefer invariant tests

Property-based invariant tests are the primary security layer. They exercise more
code paths per test than unit tests — the fuzzer explores input and call sequence
variations that no developer would write by hand. Implement a `property_` function
for every behavior worth protecting, not only for the INV-* invariants defined in
`.specs/economics/INVARIANTS.md`.

The Chimera pattern (`test/recon/`) runs the same property functions across three
runners: Foundry's invariant runner (`forge test --match-contract CryticToFoundry`),
Medusa, and Echidna. A property written once runs on all three.

### Unit tests as second option

Write a unit test when the condition is not easily expressable as a property:

- **Named revert conditions** — `revert InsufficientBalance(requested, available)`.
  The fuzzer may not generate the exact state that triggers this revert.
- **Privileged caller paths** — functions gated on `msg.sender == owner`. The fuzzer
  needs handler setup to call these; a unit test is cleaner for basic coverage.
- **Initialization logic** — constructor or initializer paths rarely reached by the
  fuzzer.

For everything else, prefer a property test over a unit test.

### When to run tests

Run `forge test --match-contract CryticToFoundry` after implementing each function
that touches an invariant. Run the full suite (`forge test`) before committing.
Run Medusa before opening a PR on a significant feature:

```bash
medusa fuzz --config medusa.json --timeout 60
```

### Coverage — 90% minimum

Coverage must reach 90% before a contract is considered complete for audit.

```bash
forge coverage --report lcov
```

Use coverage to find untested branches in `src/`. For each uncovered branch, decide:
- Can a new property function or improved handler reach it? → add the property.
- Is it a revert condition or privileged path the fuzzer won't naturally reach? → add
  a unit test.

A 90% floor with strong property tests is more valuable than 100% covered only by
unit tests. Coverage is a diagnostic — use it to find gaps, not to justify skipping
property tests.

### Test directory structure

Organize tests in four directories from the start:

```
test/
  base/        # shared fixtures and base contracts
  unit/        # isolated per-function tests
  integration/ # multi-contract end-to-end flows
  fuzz/        # Chimera-based property tests (test/recon/)
  mocks/       # mock contracts for external dependencies
```

Test-only helpers must live in `test/`, never `src/`.

### Test naming: Gherkin convention

Unit and integration tests must use Given/When/Then names:

```solidity
/// @dev Given: vault has balance
/// When:  withdraw called with full balance
/// Then:  balance reaches zero and event emitted
function test_Given_vaultHasBalance_When_withdrawFull_Then_zeroBalance() public { ... }
```

Property functions in `test/recon/` keep the `property_` prefix — they describe
invariants, not scenarios.

### Reentrant mocks

Every `nonReentrant` guard must have a test that confirms it works. Use a malicious
mock contract that calls back into the guarded function from within a callback. An
untested guard may be on the wrong function or may have been inadvertently removed.

### End-to-end integration test

Every contract system must have at least one test that walks the full happy path
from deployment to final user action — with three or more distinct user addresses
and crossing every contract boundary. Unit tests and property tests don't catch
inter-contract edge cases; the E2E test does. Place in `test/integration/`.

---

## Maintaining project documents

### INVARIANTS.md

Generated from `.specs/economics/INVARIANTS.md` during project setup. Do not edit
directly. If an invariant changes in `.specs/economics/INVARIANTS.md`:

1. Update the corresponding entry in `INVARIANTS.md`
2. Update or rename the `property_` function in `test/recon/Properties.sol`
3. Update the `assert()` in `test/recon/CryticToFoundry.sol`

### test/recon/Properties.sol

One `property_` function per invariant. Naming is mechanical:

```
INV-vault-solvency   →  property_vault_solvency()
INV-share-monotonic  →  property_share_monotonic()
```

When adding a new invariant: add the entry to `.specs/economics/INVARIANTS.md`
first, then add the stub here, then wire the `assert()` in `CryticToFoundry.sol`.
When removing: reverse the steps. No orphaned functions.

### test/recon/CryticToFoundry.sol

One `assert()` per `property_` function, with an inline comment naming the invariant:

```solidity
function invariant_properties() public view {
    assert(property_vault_solvency());        // INV-vault-solvency
    assert(property_deposit_nonzero_shares()); // INV-deposit-nonzero-shares
}
```

### test/recon/BeforeAfter.sol

One `Vars` field per state variable that any `property_` function reasons about.
Naming: `{contractName}_{variableName}`. When adding a property function, check if
it needs new fields and add reads in both `__before()` and `__after()`.

### KNOWN_ISSUES.md

**Slither / mutation finding accepted after review:**

```markdown
### [Slither] ContractName — detector-name
**Location:** `src/ContractName.sol:LINE`
**Suppression:** `// slither-disable-next-line detector`

Why it is not actionable in this context and what makes it safe.
```

**SPEC_DEVIATION (implementation diverged from spec):**

```markdown
### [SPEC_DEVIATION] REQ-{slug}
**Location:** `src/ContractName.sol:LINE`
**Spec:** [what the spec required]
**Implementation:** [what the code does instead]
**Reason:** [why]
**Spec updated:** [date]
```

Add a `[SPEC_DEVIATION]` entry for every `// SPEC_DEVIATION: REQ-*` comment in
source code. These are high-priority review points for auditors.

---

## No magic numbers

Every numeric literal in `src/` and `test/` must be assigned to a self-documenting
variable or constant before use. No exceptions — not in arithmetic, not in
comparisons, not in test setups.

```solidity
// bad
require(fee <= 1000, "fee too high");
uint256 shares = assets * 1e18 / totalAssets;

// good
uint256 constant MAX_FEE_BPS = 1000;  // 10% in basis points
require(fee <= MAX_FEE_BPS, "fee too high");

uint256 constant SHARES_PRECISION = 1e18;
uint256 shares = assets * SHARES_PRECISION / totalAssets;
```

This is especially important in calculations — a raw number in an arithmetic
expression gives no indication of what it represents or why it has that value.
A named constant makes the intent auditable and makes precision assumptions
explicit. When a constant changes, every usage is visible via the name.

In tests, use the same constants as production code where possible, and name
any test-specific amounts descriptively:

```solidity
// bad
vault.deposit(1000e6, alice);

// good
uint256 constant INITIAL_DEPOSIT = 1000e6;  // 1,000 USDC (6 decimals)
vault.deposit(INITIAL_DEPOSIT, alice);
```

---

## Pre-commit checklist

Before every commit, all of the following must be true:

1. `forge fmt --check` passes with no diff
2. `npx lintspec src/` passes
3. `forge build --sizes` is clean — zero warnings, no contract exceeds 24kB
4. `slither src/` has no unacknowledged findings (all findings either fixed or in `KNOWN_ISSUES.md`)
5. `forge test` passes
6. `forge coverage` is at 90% or above for the contracts touched by this commit

If any of these fails, fix it before committing. Do not commit a partial or broken
state — the pre-commit hook enforces `forge fmt --check` and `forge build`, but
the remaining checks are the agent's responsibility.

---

## Code conventions

### Naming

External and public function parameters must have a trailing underscore (`amount_`,
`recipient_`). Internal and private parameters do not. This distinguishes parameters
from state variables and prevents shadowing.

```solidity
function deposit(uint256 amount_, address receiver_) external { ... }
function _deposit(uint256 amount, address receiver) internal { ... }
```

All constants must use `SCREAMING_SNAKE_CASE`.

Value parameters in math-heavy functions must encode unit and direction in the name
— never generic names like `amount` or `value`. The name should tell the reader
what the number represents and what its unit is:

```solidity
// bad — what unit? what direction?
function withdraw(uint256 amount, uint256 limit) external { ... }

// good
function withdraw(uint256 assetAmount_, uint256 maxSlippageBps_) external { ... }
```

When the unit is non-obvious, reinforce it in `@param`.

### NatSpec

Use `/// @inheritdoc IFoo` in implementation contracts; never duplicate interface
NatSpec. NatSpec lives in the interface.

Add `/// @dev` to any function with behavior that looks like a bug — callable after
finalization, no access guard, etc. The comment documents deliberate intent and
prevents auditors from filing false findings.

Every production contract must include `/// @custom:security-contact security@yourorg.com`.

### Events

Every admin setter must emit an event — no exceptions. These form the on-chain
audit trail visible to monitors and governance.

For operations that perform multiple state changes in one transaction, emit a
per-component breakdown rather than a single aggregate:

```solidity
// bad
emit Settled(totalAmount);
// good
emit Settled(principalReturned, feesCollected, penaltyApplied);
```

### Style

Assign struct returns field-by-field — never via positional tuple destructuring.
Positional destructuring silently reads the wrong field after any struct reorder;
field-by-field assignment produces a compile error:

```solidity
// bad — silent breakage on struct reorder
(uint256 a, uint256 b) = getInfo();

// good — compile error if field removed or renamed
Info memory data = getInfo();
uint256 a = data.fieldA;
```

---

## Security patterns

### Reentrancy

Prefer `ReentrancyGuardTransient` (EIP-1153, Cancun) over the storage-based
`ReentrancyGuard`. Transient storage clears automatically between transactions
at no persistent storage cost.

`nonReentrant` must always be the **first** modifier — before auth and business
modifiers:

```solidity
// correct
function withdraw() external nonReentrant onlyOwner whenNotPaused { ... }
// wrong — auth runs before the guard
function withdraw() external onlyOwner nonReentrant { ... }
```

### Ownership and upgradeability

Use `Ownable2Step` (or `Ownable2StepUpgradeable`) for every contract with
privileged functions. Plain `Ownable` allows irreversible fat-finger transfers —
`Ownable2Step` requires the new owner to call `acceptOwnership()` explicitly.

In every UUPS implementation constructor, call `_disableInitializers()`. Without
it, an attacker can initialize the implementation directly.

Default instance-level contracts (markets, vaults, individual pools) to
non-upgradeable. Add UUPS only where there is a concrete, documented reason —
it adds bytecode, attack surface, and audit scope.

### Idempotency

Guard one-shot operations with an explicit `bool` flag — never a zero-value check.
Zero is a legitimate result in loss or empty scenarios:

```solidity
// bad — zero is valid (e.g. total-loss scenario)
if (settledAmount > 0) return;
// good
if (settled) return;
```

### Push payments in batches

Never use bare `safeTransfer` inside a loop over multiple recipients on a critical
path. One blacklisted or reverting recipient permanently freezes the operation.
Pattern: attempt the transfer, escrow on failure, expose a pull function:

```solidity
(bool ok,) = address(token).call(abi.encodeCall(token.safeTransfer, (user, amount)));
if (!ok) failedTransfers[user] += amount; // claimable via pullPayment(to_)
```

### Loop safety

Do not `revert` inside a loop over shared mutable state (queues, lists, mappings).
A single entry that triggers the revert bricks every future call to that loop.
Convert to skip-and-cleanup: remove or skip the offending entry and continue.

---

## Contract size

When `forge build --sizes` shows a contract approaching 20 kB, apply in order:

1. **Lens pattern** — move all view and derived-read functions to `XLens.sol`.
   Deploy separately; frontends and scripts call the Lens, not the core contract.
2. **`optimizer_runs = 1`** — in `foundry.toml`, optimizes for deploy-size over
   runtime gas. Apply only to the constrained contract, not to math libraries.
3. **Extract `pure` functions to a library** — shared across 2+ contracts, `pure`
   functions belong in a `library`. `internal` visibility inlines them at zero cost;
   `external` deploys separately and saves bytecode for large, rarely-called logic.
4. **Move validation to the factory** — in factory + clones patterns, all input
   validation lives in the factory. Clones assume valid inputs and have minimal
   `initialize()` bodies.
5. **Remove UUPS from instances** — removes ~200–300 bytes. Default immutable for
   per-instance contracts unless there is a concrete, documented reason.


---

## Deployment

### Secrets

Private keys must never appear in committed files. Load them from a secret manager
(AWS Secrets Manager, 1Password CLI) at runtime. Use `.env.example` to document
variable names without values.

### Deploy script structure

- **`DeployConfig.sol`** — network-specific parameters (token addresses, treasury,
  fee thresholds). Import it into deploy scripts; never hardcode addresses inline.
- Gate testnet-only actions with `if (block.chainid != MAINNET_CHAIN_ID)` to
  prevent local logic from running on mainnet.

### CI pinning

Pin the Foundry toolchain version in CI:

```yaml
- uses: foundry-rs/foundry-toolchain@v1
  with:
    version: 'v1.7.0'   # pin explicitly; never use "latest" or "nightly"
```

Floating toolchain versions cause silent divergence in formatter output and compiler
behavior between CI and local environments.
