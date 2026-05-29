# Agent Development Guide

Instructions for AI coding agents working in this repository.
Keep this file updated when the toolchain changes — agents read it to know
how to run checks, fix issues, and maintain project documents.

---

## Available commands

| Command | When | What it checks |
|---|---|---|
| `forge fmt` | Before every commit | Auto-fixes formatting |
| `forge fmt --check` | CI gate | Formatting is clean (no diff) |
| `forge build` | After any change | Compilation, zero warnings |
| `forge test` | Before push | All unit + fuzz tests pass |
| `forge coverage --report lcov` | Manual / CI | Coverage report |
| `slither src/` | Manual / CI | Static analysis |
| `npx lintspec` | Manual / CI | NatSpec completeness |
| `bash scripts/mutate.sh` | Before audits | Mutation testing |
| `medusa fuzz --config medusa.json --timeout 60` | Nightly / manual | Property-based fuzzing |
| `halmos` | Nightly / manual | Symbolic proofs |
| `bash scripts/snapshot.sh` | Before hot-path PRs | Gas regression check |
| `bash scripts/snapshot.sh --check` | Manual gate | Fails if gas regressed |

Git hooks run automatically:
- **pre-commit**: `forge fmt --check` + `forge build` (zero warnings)
- **pre-push**: `forge test`

---

## Gate check per function complexity

When implementing a function, the gate check that must pass before marking it `verified` in IMPL-TASKS.md:

### simple functions
```bash
forge build          # compile clean, zero warnings
forge fmt --check    # formatting clean
```
One unit test: happy path + one obvious revert. No fuzz required.

### medium functions
```bash
forge build
forge fmt --check
forge test --match-test <FunctionName>
```
One unit test (happy path + critical reverts) + scenario test if a threat model entry exists.

### complex functions
```bash
forge build
forge fmt --check
forge test --match-test <FunctionName>
```
Full suite: fuzz test (linked to INV-* from `test/recon/Properties.sol`) + scenario test + unit tests. All must pass.

After implementing all functions in a contract:
```bash
forge test              # full suite
slither src/            # static analysis — triage all findings before marking contract complete
npx lintspec src/       # NatSpec completeness — all public/external functions must be documented
```

---

## Fixing issues

### `forge fmt` failures
Run `forge fmt` (no flags) to auto-fix. Re-stage the formatted files. Never manually reformat — always let the tool do it.

### `forge build` warnings
Zero warnings is the policy. Fix the root cause — do not suppress without a documented reason.

### `lintspec` failures
Add missing `@notice`, `@param`, `@return` tags to the flagged function. Every public and external function, event, error, and struct requires NatSpec. Example:
```solidity
/// @notice Deposits USDC and mints vault shares to the receiver
/// @param assets Amount of USDC to deposit (6 decimals)
/// @param receiver Address that receives the minted shares
/// @return shares Number of shares minted
function deposit(uint256 assets, address receiver) external returns (uint256 shares) {
```

### Slither findings
For each finding:
1. **Actionable**: fix the root cause. Do not suppress until the underlying issue is addressed.
2. **False positive / accepted risk**: add an entry to `KNOWN_ISSUES.md` (see below) and add an inline suppression:
```solidity
// slither-disable-next-line reentrancy-no-eth
// Reason: CEI pattern enforced and nonReentrant guard active — see KNOWN_ISSUES.md §reentrancy-no-eth
```
Every inline suppression must have a corresponding `KNOWN_ISSUES.md` entry. The comment must reference the section.

---

## Maintaining project documents

### INVARIANTS.md (project root)
Generated from `.specs/economics/INVARIANTS.md` during project setup. Do not edit directly.
If an invariant changes in `.specs/economics/INVARIANTS.md`, re-run the bridge:
- Update the corresponding entry in `INVARIANTS.md`
- Update the `property_` function stub or implementation in `test/recon/Properties.sol`
- Update the `assert()` in `CryticToFoundry.sol` if the function was renamed or removed

### test/recon/Properties.sol
One `property_` function per INV-* entry in `INVARIANTS.md`. Naming convention:
```
INV-vault-solvency → property_vault_solvency()
INV-share-monotonic → property_share_monotonic()
```

When adding a new invariant:
1. Add the INV-* entry to `.specs/economics/INVARIANTS.md` first
2. Add the entry to `INVARIANTS.md`
3. Add the property stub to `Properties.sol`
4. Add the `assert()` to `CryticToFoundry.sol → invariant_properties()`

When removing an invariant: reverse the steps. Do not leave orphaned `property_` functions.

### test/recon/CryticToFoundry.sol — invariant_properties()
Must have exactly one `assert()` per `property_` function in `Properties.sol`. Keep comments aligned:
```solidity
function invariant_properties() public view {
    assert(property_vault_solvency());        // INV-vault-solvency
    assert(property_deposit_nonzero_shares()); // INV-deposit-nonzero-shares
}
```

### test/recon/BeforeAfter.sol
Captures state snapshots before and after each call. Add a field for every state variable that any `property_` function reasons about. Naming: `{contractName}_{variableName}`.

When adding a new property function: check if it needs new `Vars` fields. If yes, add the field, and add reads in both `__before()` and `__after()`.

### KNOWN_ISSUES.md
Two types of entries:

**Slither / mutation findings** (accepted after review):
```markdown
### [Slither] ContractName — detector-name

**Location:** `src/ContractName.sol:LINE`
**Suppression:** `// slither-disable-next-line detector`

One paragraph: what Slither flagged, why it is not actionable in this context,
what invariant or upstream constraint makes it safe.
```

**SPEC_DEVIATION entries** (implementation diverged from spec):
```markdown
### [SPEC_DEVIATION] REQ-{slug}

**Location:** `src/ContractName.sol:LINE`
**Spec requirement:** [what the spec said]
**Actual implementation:** [what the code does instead]
**Reason:** [why the deviation was necessary]
**Spec updated:** [date]
```

Add a SPEC_DEVIATION entry whenever `// SPEC_DEVIATION: REQ-*` appears in source code. These are high-priority review points for auditors.

---

## Adding new contracts

When a new contract is added to `src/`:
1. Add it to the `Setup.sol` deployment in `test/recon/`
2. Add relevant `Vars` fields to `BeforeAfter.sol`
3. Add handler functions to `TargetFunctions.sol` for the functions the fuzzer should call
4. Run `bash scripts/recon.sh` if Recon CLI is installed — regenerates scaffolding from current contracts
5. Run `forge test` to verify the Chimera suite still passes

---

## Gas snapshot workflow

Before opening a PR that touches a hot path (deposit, withdraw, harvest):
```bash
bash scripts/snapshot.sh --check   # fails if gas regressed
bash scripts/snapshot.sh           # update after intentional change
```

Commit the updated `.gas-snapshot` alongside the implementation change. Do not commit a snapshot update without the corresponding implementation change.
