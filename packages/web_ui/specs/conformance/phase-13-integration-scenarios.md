# Phase 13 Integration Scenarios

## Purpose

Define conformance scenarios for expanded outcome-envelope hints and deterministic UI reconciliation.

## Outcome Hint Scenarios

1. `SCN-018`: runtime success outcomes include normalized `ui_hints` payload shape.
2. `SCN-018`: transport roundtrip preserves `ui_hints` continuity in `runtime.event.recv.v1` payloads.
3. `SCN-018`: UI runtime reconciliation applies hints deterministically and clears stale hints on error.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_13_outcome_hints_test.exs
./scripts/run_conformance.sh --report-only
```
