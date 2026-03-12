# Phase 14 Integration Scenarios

## Purpose

Define conformance scenarios for release gate regression hardening and fail-closed governance behavior.

## Release Gate Regression Scenarios

1. `SCN-019`: report-only release gate emits deterministic stage and pass markers on clean inputs.
2. `SCN-019`: regression probe passes for clean inputs and detects false-positive risks.
3. `SCN-019`: injected unknown-scenario defects trigger fail-closed governance diagnostics.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_14_release_gate_regression_test.exs
./scripts/check_release_gate_regressions.sh
./scripts/run_conformance.sh --report-only
```
