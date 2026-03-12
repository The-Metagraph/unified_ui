# Phase 18 Integration Scenarios

## Purpose

Define conformance scenarios for deterministic turn metadata propagation and turn-state reconciliation.

## Turn Execution Scenarios

1. `SCN-023`: outbound runtime dispatch payloads include deterministic `turn_id` metadata derived from `dispatch_sequence`.
2. `SCN-023`: result reconciliation clears `active_turn_id` and records `last_completed_turn_id` deterministically.
3. `SCN-023`: repeated equivalent flows produce equivalent turn progression traces.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_18_turn_execution_test.exs
./scripts/run_conformance.sh --report-only
```
