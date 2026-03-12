#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/scan_rfc_governance_debt.sh [--strict] [--max-draft-age-days N]

Options:
  --strict                 Exit with code 1 when governance debt is found.
  --max-draft-age-days N   Maximum allowed age for Draft RFCs (default: 45).
USAGE
}

ROOT="${RFC_GOVERNANCE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$ROOT"

STRICT=0
MAX_DRAFT_AGE_DAYS="${MAX_DRAFT_AGE_DAYS:-45}"
EXTERNAL_RFC_IDS_REGEX='^(RFC-2119)$'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict)
      STRICT=1
      shift
      ;;
    --max-draft-age-days)
      MAX_DRAFT_AGE_DAYS="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ ! "$MAX_DRAFT_AGE_DAYS" =~ ^[0-9]+$ ]]; then
  echo "ERROR: --max-draft-age-days must be an integer"
  exit 1
fi

if [[ ! -d "rfcs" ]]; then
  echo "INFO: no rfcs/ directory found; skipping governance debt scan."
  exit 0
fi

if [[ ! -f "rfcs/index.md" ]]; then
  echo "ERROR: missing rfcs/index.md"
  exit 1
fi

date_to_epoch() {
  local value="$1"

  if date -d "$value" +%s >/dev/null 2>&1; then
    date -d "$value" +%s
    return 0
  fi

  if date -j -f "%Y-%m-%d" "$value" +%s >/dev/null 2>&1; then
    date -j -f "%Y-%m-%d" "$value" +%s
    return 0
  fi

  return 1
}

trim() {
  echo "$1" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

debt_count=0

report_debt() {
  local category="$1"
  local message="$2"
  echo "DEBT [$category]: $message"
  debt_count=$((debt_count + 1))
}

rfc_files="$(rg --files rfcs | rg '^rfcs/RFC-[0-9]{4}-[a-z0-9][a-z0-9-]*\.md$' | sort || true)"
file_ids="$(echo "$rfc_files" | sed -E 's#^rfcs/(RFC-[0-9]{4})-.+#\1#' | sed '/^$/d' | sort -u || true)"
index_ids="$(rg -o 'RFC-[0-9]{4}' rfcs/index.md | sort -u || true)"

while IFS= read -r id; do
  [[ -z "$id" ]] && continue
  if ! echo "$index_ids" | grep -Fxq "$id"; then
    report_debt "unindexed-rfc" "$id exists as file but is missing from rfcs/index.md"
  fi
done <<< "$file_ids"

while IFS= read -r id; do
  [[ -z "$id" ]] && continue
  if ! echo "$file_ids" | grep -Fxq "$id"; then
    report_debt "orphaned-index-row" "$id is listed in rfcs/index.md but no matching RFC file exists"
  fi
done <<< "$index_ids"

now_epoch="$(date +%s)"
max_age_seconds=$((MAX_DRAFT_AGE_DAYS * 86400))

while IFS= read -r rfc; do
  [[ -z "$rfc" ]] && continue

  status="$(rg -o '^- Status: `[^`]+`$' "$rfc" | head -n1 | sed -E 's/.*`([^`]+)`.*/\1/' || true)"
  created="$(rg -o '^- Created: `[0-9]{4}-[0-9]{2}-[0-9]{2}`$' "$rfc" | head -n1 | sed -E 's/.*`([^`]+)`.*/\1/' || true)"

  if [[ "$status" == "Draft" && -n "$created" ]]; then
    if created_epoch="$(date_to_epoch "$created" 2>/dev/null)"; then
      age_seconds=$((now_epoch - created_epoch))
      if [[ "$age_seconds" -gt "$max_age_seconds" ]]; then
        age_days=$((age_seconds / 86400))
        report_debt "stale-draft" "$(basename "$rfc") has been Draft for $age_days days (created $created)"
      fi
    else
      report_debt "invalid-created-date" "$(basename "$rfc") has an unparsable Created date '$created'"
    fi
  fi
done <<< "$rfc_files"

spec_referenced_ids="$(rg -o --no-filename 'RFC-[0-9]{4}' specs | sort -u || true)"
while IFS= read -r id; do
  [[ -z "$id" ]] && continue
  if echo "$id" | rg -q "$EXTERNAL_RFC_IDS_REGEX"; then
    continue
  fi
  if ! echo "$file_ids" | grep -Fxq "$id"; then
    report_debt "broken-spec-reference" "specs references $id but no matching RFC file exists"
  fi
done <<< "$spec_referenced_ids"

if [[ "$debt_count" -eq 0 ]]; then
  echo "RFC governance debt scan: no findings."
  exit 0
fi

echo "RFC governance debt scan: $debt_count finding(s)."

if [[ "$STRICT" -eq 1 ]]; then
  exit 1
fi

exit 0
