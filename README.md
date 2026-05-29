# foundry-security-template

A Foundry boilerplate for Solidity/DeFi protocols with a full CI pipeline, security toolchain, and local git hooks wired up from day one.

**Use this template** via the GitHub "Use this template" button — don't clone it directly.

---

## What's included

**Per-commit / per-PR (fast, blocking):**

| Gate | When | What it checks |
|------|------|----------------|
| `forge fmt --check` | pre-commit, CI | Style consistency |
| `forge build` | pre-commit, CI | Compilation; zero warnings |
| EIP-170 size limit | CI | No contract exceeds 24,576B |
| `forge test` | pre-push, CI | Unit + fuzz tests |
| `forge coverage` | CI | Coverage report (lcov artifact) |
| Slither | CI (separate job) | Static analysis |
| lintspec | CI | NatSpec completeness |

**Nightly (heavy, non-blocking):**

| Gate | What it checks |
|------|----------------|
| Medusa | Property-based fuzzing with persistent corpus |
| Halmos | Symbolic proofs (`check_` functions) |
| `slither-mutate` | Mutation testing (reports survivors) |

**Scaffolding:**

| Tool | Purpose |
|------|---------|
| Recon (Chimera pattern) | `test/recon/` — property test structure for Medusa/Echidna/forge |
| `medusa.json` | Medusa fuzzer config (10 workers, corpus persistence) |
| `echidna.yaml` | Echidna fuzzer config (same `property_` functions, alternative runner) |
| `scripts/recon.sh` | Regenerates `test/recon/` scaffolding when contracts change |
| `scripts/mutate.sh` | Runs mutation testing locally |
| `scripts/snapshot.sh` | Updates or checks `.gas-snapshot` (manual gate before hot-path PRs) |

Slither and lintspec run as separate jobs — a Slither warning has different
implications than a test failure.

---

## Getting started

```bash
# 1. Clone your repository from the template
git clone git@github.com:your-org/your-repo.git && cd your-repo
# or, using this template directly:
# gh repo create your-org/your-repo --template melanke/foundry-security-template --private --clone

# 2. Install git hooks
bash scripts/install-hooks.sh

# 3. Configure environment
cp .env.example .env   # fill in RPC URLs and keys as needed

# 4. Install dependencies
forge install

# 5. Run the test suite
forge test

# 6. Check formatting
forge fmt --check
```

---

## Configuration

### Foundry version

The CI pipeline pins Foundry to a specific version in every workflow file. Update
it intentionally — Foundry updates can silently shift gas semantics and affect
gas-budget assertions. Search for `version: "v1.7.0"` across `.github/workflows/`
to update all jobs at once.

### Optimizer runs

`foundry.toml` defaults to `optimizer_runs = 200` (the Foundry default). Adjust
based on your bottleneck:

- `1` — smallest bytecode; useful for contracts near the EIP-170 24,576B limit
- `200` — balanced default
- `10_000+` — cheapest repeated calls; for pure math libraries called in loops

Note that `optimizer_runs` is a per-contract decision. If a specific contract
needs a different setting, consider extracting its hot-path logic into a library
and setting per-profile overrides.

### Solidity version

Pinned to `0.8.25` in `foundry.toml`. Update alongside Foundry intentionally.

### Formatter

Configured in the `[fmt]` block of `foundry.toml`. `int_types = "long"` enforces
`uint256` over `uint`, preventing ABI-level surprises. `number_underscore = "thousands"`
enforces `10_000` over `10000`, eliminating digit-counting errors in constants.

---

## Adding dependencies

```bash
forge install OpenZeppelin/openzeppelin-contracts
forge install transmissions11/solmate
```

Dependencies install as git submodules under `lib/`. Pin them to specific commits
rather than tracking branches — reproducible builds require a fixed dependency tree.

---

## Deployment

Scripts live in `script/`. The entry point is `run()` inside a contract that
extends `Script`. Deploy with `--account` (a named keystore) rather than
`--private-key` to keep secrets out of shell history and environment variables.

### Setting up wallets

**Local development** — Anvil's default key, no password needed:

```bash
cast wallet import ForgeDefault --interactive
# paste: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
# address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

**Production** — import your real deployer key once, use the account name everywhere:

```bash
cast wallet import ProductionDeployer --interactive
# paste your private key; set a strong password
# note the address and add it to .env as DEPLOYER_ADDRESS
```

### Running a script

```bash
# Local (Anvil must be running: anvil)
forge script script/Counter.s.sol:CounterScript \
  --rpc-url $LOCAL_URL \
  --account ForgeDefault \
  --broadcast

# Testnet / mainnet
forge script script/Counter.s.sol:CounterScript \
  --rpc-url $RPC_URL \
  --account ProductionDeployer \
  --broadcast \
  --verify
```

`--broadcast` sends the transactions. Without it, the script runs as a dry-run.
`--verify` submits source code to Etherscan after deployment (requires `ETHERSCAN_API_KEY` in `.env`).

Broadcast artifacts (transaction hashes, deployed addresses) are saved to
`broadcast/` and committed to the repo — they are the authoritative record of
what was deployed where.

---

## Static analysis

`slither.config.json` filters `lib/` so vendored code doesn't trigger false
positives. Detectors to suppress project-wide go in `detectors_to_exclude`.

For per-occurrence suppression, use inline comments:

```solidity
// block.timestamp acceptable at ~30min resolution — exact ordering doesn't matter.
// See KNOWN_ISSUES.md §timestamp.
// slither-disable-next-line timestamp
require(block.timestamp >= resolutionTime, "TooEarly");
```

Every suppression — inline or project-level — needs a corresponding entry in
`KNOWN_ISSUES.md` explaining *why* it was accepted.

---

## Mutation testing

`slither-mutate` ships with Slither — no extra installation needed. It runs **nightly**
rather than on every PR because the tool invokes a full recompile cycle per mutant
(~30-40 seconds each via crytic-compile). A contract with 50 mutants takes ~30 minutes;
running that on every PR would make CI unusable.

Run locally before audits or before merging large changes:

```bash
bash scripts/mutate.sh                 # mutate all src/ contracts
bash scripts/mutate.sh Counter,Vault   # mutate specific contracts
```

This step **reports** uncaught mutants but does not fail CI (slither-mutate exits 0).
Triage each survivor:

- **Semantically equivalent** (e.g., `a++` vs `++a` where the return value is unused):
  document in `KNOWN_ISSUES.md` — it cannot be killed by a meaningful test.
- **Real gap** (behavior not asserted by any test): write the missing assertion.

Mutation testing and coverage are complementary: mutation testing finds assertion gaps;
coverage tracks the overall floor.

To run on every PR instead of nightly: in `mutation.yml`, replace the `schedule` trigger
with `pull_request: { branches: [main] }` and accept the CI cost.

---

## NatSpec

lintspec enforces `@notice`, `@param`, and `@return` on every public and external
function, event, error, and struct. Adding a new public API without NatSpec will
fail CI.

To also enforce on internal functions, run `lintspec init` to generate
`.lintspec.toml` and adjust the visibility rules.

---

## Coverage

`forge coverage --report lcov` generates `lcov.info`, uploaded as a CI artifact.
Pair it with the **Coverage Gutters** VS Code extension to see untested branches
inline while writing code.

No hard threshold is enforced out of the box — define your floor in the CI
workflow once the codebase matures. Coverage distorts gas readings; if you add
gas-budget assertions, run them under `FOUNDRY_PROFILE=default` and coverage
under `FOUNDRY_PROFILE=coverage` (see `foundry.toml`).

---

## Property-based fuzzing (Medusa)

The `test/recon/` directory uses the **Chimera pattern** generated by Recon:

```
test/recon/
  Setup.sol            — deploys all contracts under test
  BeforeAfter.sol      — captures state snapshots before/after each call
  Properties.sol       — your protocol invariants (property_ functions)
  TargetFunctions.sol  — handler wrappers the fuzzer will call
  CryticToFoundry.sol  — entry point for Medusa, Echidna, and forge invariant
```

The same test suite runs with three different runners:

```bash
medusa fuzz --config medusa.json --timeout 60          # Medusa
echidna . --contract CryticToFoundry --config echidna.yaml  # Echidna
forge test --match-contract CryticToFoundry            # Foundry invariant runner
```

Medusa and Echidna both use the same `property_` functions. Choose one as your
primary nightly runner — Medusa is configured in CI. `echidna.yaml` is provided
for teams that prefer Echidna or want to cross-check results.

When you add contracts, regenerate the scaffolding:
```bash
bash scripts/recon.sh   # requires: cargo install recon-cli
```

Medusa runs nightly with **corpus persistence** — each run builds on the last.
The corpus is stored in GitHub Actions cache (not committed to the repo).
`corpus/` and `corpus-echidna/` are gitignored; CI saves and restores automatically.

---

## Formal verification (Halmos)

`test/symbolic/` contains `check_` functions — formal proofs, not fuzz tests.
A passing Halmos check means no counterexample exists within the specified bounds.

```bash
halmos --match-contract CounterProofTest --loop 4
```

When a check times out (marked `unknown`):
- Add `vm.assume()` to tighten the input space
- Increase `--solver-timeout-assertion` (costs more CI time)
- Split the property into smaller, bounded checks

Halmos runs nightly at 04:00 UTC and on `workflow_dispatch`.

---

## Gas snapshots

`.gas-snapshot` records the gas cost of every test. Use it as a manual gate
before opening PRs that touch hot paths:

```bash
bash scripts/snapshot.sh           # update after an intentional change
bash scripts/snapshot.sh --check   # fail if any test regressed
```

Commit `.gas-snapshot` to establish the baseline. Not wired into CI because
snapshot values shift with Foundry version upgrades — treating it as a blocking
gate would produce false failures on every toolchain update.

---

## Repository conventions

- `KNOWN_ISSUES.md` — accepted Slither findings, each with a justification
- `INVARIANTS.md` — protocol invariants mapped to `property_` functions in `test/recon/Properties.sol`
- `SECURITY.md` — responsible disclosure policy; update the contact email before deploying
- `.env.example` — copy to `.env` (gitignored) and fill in RPC URLs and keys
- `src/` — production contracts only; no test helpers
- `test/` — unit/fuzz tests (`*.t.sol`), Recon scaffolding (`test/recon/`), symbolic proofs (`test/symbolic/`)
- `script/` — deployment and operational scripts
- `corpus/` — Medusa corpus (gitignored; persisted via CI cache)
- `corpus-echidna/` — Echidna corpus (gitignored; local only)
- `.gas-snapshot` — committed gas baseline; update intentionally
