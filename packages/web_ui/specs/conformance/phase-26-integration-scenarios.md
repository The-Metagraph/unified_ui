# Phase 26 Integration Scenarios

## Purpose

Define conformance scenarios for deterministic replay baseline registry ordering, activation, and gate-resolution behavior.

## Replay Baseline Registry Scenarios

1. `SCN-031`: equivalent baseline capture flows produce deterministic registry ordering and active-baseline selection.
2. `SCN-031`: baseline activation and gate-resolution paths produce deterministic pass/fail diagnostics.
3. `SCN-031`: repeated equivalent registry flows produce equivalent baseline-registry traces.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_26_replay_baseline_registry_test.exs
./scripts/run_conformance.sh --report-only
```
