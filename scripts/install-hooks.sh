#!/usr/bin/env bash
# Configures git to use the project's .githooks/ directory.
# Run once after cloning: bash scripts/install-hooks.sh
set -euo pipefail

git config core.hooksPath .githooks
chmod +x .githooks/*

echo "Git hooks installed (core.hooksPath = .githooks)"
