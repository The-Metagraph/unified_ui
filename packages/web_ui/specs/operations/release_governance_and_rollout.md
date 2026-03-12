# Release Governance and Rollout

## Purpose

Define deterministic release gates, rollout phases, and rollback triggers for the first production-viable slice.

## Pre-Release Governance Gate

All release candidates MUST pass:

1. Specs governance validation.
2. RFC governance validation.
3. RFC governance debt strict scan.
4. Conformance harness alignment + deterministic conformance tests.
5. Full test suite.

Canonical command:

```bash
./scripts/run_release_readiness.sh
```

Report-only command (no full `mix test`):

```bash
./scripts/run_release_readiness.sh --report-only
```

Regression probe command (false-positive/false-negative guardrails):

```bash
./scripts/check_release_gate_regressions.sh
```

## Required Artifacts

Before publishing a release tag, capture and retain:

1. `release-readiness-report.log` from CI/manual run.
2. Conformance report artifact (`conformance-report.log`).
3. RFC index row/status updates for RFCs delivered in the release.

## Staged Rollout Policy

### Stage 0: Internal Canary

- Scope: internal users only.
- Duration: minimum 30 minutes.
- Go criteria:
1. No sustained increase in `webui_event_decode_error_total`.
2. No sustained increase in `webui_event_encode_error_total`.
3. `webui_service_operation_latency` p95 remains within agreed baseline.

### Stage 1: Limited External Rollout

- Scope: 25% of traffic/sessions.
- Duration: minimum 2 hours.
- Go criteria:
1. Error metrics remain below rollback thresholds.
2. No unresolved P1/P2 incident.
3. Correlation joinability diagnostics remain green.

### Stage 2: Full Rollout

- Scope: 100% traffic.
- Requires explicit go/no-go decision from release owner.

## Rollback Triggers

Immediate rollback SHOULD be executed when any condition is met for 10+ minutes:

1. `webui_event_decode_error_total` or `webui_event_encode_error_total` exceeds 2x baseline.
2. Retryable runtime errors exceed error budget threshold for release window.
3. `webui_service_operation_latency` p95 exceeds 2x baseline on first-slice operations.
4. Correlation joinability failures prevent event-to-metric incident diagnosis.

## Rollback Actions

1. Disable staged rollout and route traffic back to previous stable release.
2. Preserve observability artifacts (events, metrics, logs, report outputs).
3. Open governance-debt issue if release gate false negatives are identified.
4. Link incident details in [`replay_recovery_incident_runbook.md`](./replay_recovery_incident_runbook.md).

## Operator Runbook Entries

Use [`replay_recovery_incident_runbook.md`](./replay_recovery_incident_runbook.md) for:

1. transport interruption recovery handling,
2. retry/cancel flow incident triage,
3. state continuity verification after reconnect.
