# Phase 31 Integration Scenarios

## Purpose

Define conformance scenarios for deterministic deep canonical value normalization and style parity between equivalent struct and map descriptor inputs.

## Deep Value and Style Parity Scenarios

1. `SCN-036`: equivalent canonical nested struct/map descriptor inputs produce identical normalized deep descriptor snapshots.
2. `SCN-036`: canonical style struct/map payloads normalize to the same deep map value shape in interpreted widget props.
3. `SCN-036`: malformed nested payloads fail closed with typed validation errors while preserving deterministic behavior.

## Validation Command

```bash
mix test test/web_ui/integration/phase_31_canonical_unified_iur_deep_value_parity_test.exs
```
