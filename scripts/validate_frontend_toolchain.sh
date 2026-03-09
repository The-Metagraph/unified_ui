#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/validate_frontend_toolchain.sh [--report-only] [--skip-install]

Options:
  --report-only   Validate frontend toolchain file/layout wiring only.
  --skip-install  Skip dependency install; requires assets/node_modules to exist.
USAGE
}

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ASSETS_DIR="$ROOT/assets"

REPORT_ONLY=0
SKIP_INSTALL=0

for arg in "$@"; do
  case "$arg" in
    --report-only) REPORT_ONLY=1 ;;
    --skip-install) SKIP_INSTALL=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg"
      usage
      exit 1
      ;;
  esac
done

require_file() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    echo "FAIL: missing required file: ${path#$ROOT/}"
    exit 1
  fi
}

if [[ ! -d "$ASSETS_DIR" ]]; then
  echo "FAIL: missing assets directory: ${ASSETS_DIR#$ROOT/}"
  exit 1
fi

require_file "$ASSETS_DIR/package.json"
require_file "$ASSETS_DIR/tailwind.config.cjs"
require_file "$ASSETS_DIR/elm.json"
require_file "$ASSETS_DIR/css/app.css"
require_file "$ASSETS_DIR/src/Main.elm"
require_file "$ASSETS_DIR/js/app.js"

if [[ "$REPORT_ONLY" -eq 1 ]]; then
  echo "Frontend toolchain wiring checks passed (report-only)."
  exit 0
fi

if ! command -v node >/dev/null 2>&1; then
  echo "FAIL: node is required but was not found on PATH."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "FAIL: npm is required but was not found on PATH."
  exit 1
fi

if [[ "$SKIP_INSTALL" -eq 1 ]]; then
  if [[ ! -d "$ASSETS_DIR/node_modules" ]]; then
    echo "FAIL: --skip-install requested but assets/node_modules is missing."
    echo "Run: mix assets.setup"
    exit 1
  fi
else
  if [[ -f "$ASSETS_DIR/package-lock.json" ]]; then
    npm --prefix "$ASSETS_DIR" ci
  else
    npm --prefix "$ASSETS_DIR" install
  fi
fi

npm --prefix "$ASSETS_DIR" run build

require_file "$ASSETS_DIR/dist/app.css"
require_file "$ASSETS_DIR/dist/app.js"

echo "Frontend toolchain validation passed."
