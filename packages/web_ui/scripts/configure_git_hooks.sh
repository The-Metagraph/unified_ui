#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

git config core.hooksPath .githooks

echo "Configured git hooks path: .githooks"
echo "Hooks now active: pre-commit, pre-push"
