# Phase 32 Integration Scenarios

## Purpose

Define conformance scenarios for deterministic canonical nested default-profile parity between equivalent struct and map descriptor inputs.

## Nested Default Profile Parity Scenarios

1. `SCN-037`: equivalent canonical nested struct/map inputs with default-profile differences produce identical interpreted snapshots.
2. `SCN-037`: canonical nested style/table-column defaults are pruned while non-default nested values remain intact.
3. `SCN-037`: malformed nested payloads fail closed with typed validation errors under nested default-profile normalization flow.

## Validation Command

```bash
mix test test/web_ui/integration/phase_32_canonical_unified_iur_nested_default_parity_test.exs
```
