# Phase 06 Integration Scenarios

## Purpose

Define conformance scenarios for custom widget registration governance and extension-boundary enforcement.

## Custom Widget Governance Scenarios

1. `SCN-009`: valid custom widget registrations succeed, while duplicate/invalid registrations fail closed with typed errors.
2. `SCN-010`: reserved built-in IDs remain protected against custom override attempts.
3. `SCN-011`: custom widget lifecycle and denied-extension telemetry events preserve correlation/request continuity.

## Validation Commands

```bash
mix test test/web_ui/integration/phase_06_custom_widget_governance_test.exs
./scripts/run_conformance.sh --report-only
```
