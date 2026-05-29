#!/usr/bin/env bash
# Run mutation testing locally on specific contracts.
# Usage:
#   bash scripts/mutate.sh                    # mutate all src/ contracts
#   bash scripts/mutate.sh Counter,Vault      # mutate specific contracts
set -euo pipefail

CONTRACTS="${1:-}"
TIMEOUT="${MUTATION_TIMEOUT:-120}"

ARGS=(
  "."
  --test-cmd "forge test"
  --test-dir test/
  --ignore-dirs lib/
  --timeout "$TIMEOUT"
)

if [ -n "$CONTRACTS" ]; then
  ARGS+=(--contract-names "$CONTRACTS")
fi

echo "Running slither-mutate ${CONTRACTS:+on: $CONTRACTS}"
slither-mutate "${ARGS[@]}"
