# Phase 15 Integration Scenarios

## Purpose

Define conformance scenarios for session resume cursor continuity and deterministic replay acknowledgement handling.

## Session Resume Continuity Scenarios

1. `SCN-020`: reconnect join commands include deterministic `resume_from_sequence` cursor metadata.
2. `SCN-020`: reconnect dedupe keys include both topic and resume cursor so cursor changes emit fresh joins.
3. `SCN-020`: join acknowledgements with resume sequence update deterministic recovery diagnostics.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_15_session_resume_continuity_test.exs
./scripts/run_conformance.sh --report-only
```
