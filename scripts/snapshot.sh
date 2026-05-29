#!/usr/bin/env bash
# Manage the gas snapshot (.gas-snapshot).
#
# Usage:
#   bash scripts/snapshot.sh           # update snapshot
#   bash scripts/snapshot.sh --check   # fail if any function regressed
#
# Run --check before opening a PR that touches hot paths.
# Run without --check after intentional gas changes to commit the new baseline.
set -euo pipefail

if [[ "${1:-}" == "--check" ]]; then
  echo "Checking gas against .gas-snapshot..."
  forge snapshot --check
  echo "✓ No gas regressions"
else
  forge snapshot
  echo "Snapshot updated: .gas-snapshot"
  echo "Commit .gas-snapshot to establish the new baseline."
fi
