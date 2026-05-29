#!/usr/bin/env bash
# Regenerates the Recon scaffolding for all contracts in src/.
#
# Run this after adding or significantly changing contracts:
#   bash scripts/recon.sh
#
# Recon generates handlers and property boilerplate in test/recon/ based on
# your contract ABIs. The generated files are a starting point — review them
# and add your invariants to Properties.sol.
#
# Install Recon: https://getrecon.xyz
#   cargo install recon-cli
#   (or download from https://github.com/Recon-Labs/recon/releases)
set -euo pipefail

if ! command -v recon &>/dev/null; then
  echo "recon not found. Install: cargo install recon-cli"
  echo "Docs: https://getrecon.xyz"
  exit 1
fi

forge build

echo "Running: recon gen --src src/ --out test/recon/"
recon gen --src src/ --out test/recon/

echo ""
echo "Next steps:"
echo "  1. Review test/recon/Properties.sol — add your protocol invariants"
echo "  2. Review test/recon/TargetFunctions.sol — adjust call wrappers if needed"
echo "  3. Run: forge test --match-contract CryticToFoundry"
echo "  4. Run: medusa fuzz --config medusa.json --timeout 60"
