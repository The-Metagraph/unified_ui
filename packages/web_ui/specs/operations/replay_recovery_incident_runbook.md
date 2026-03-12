# Replay Recovery Incident Runbook

## Purpose

Provide operator guidance for transport interruption, reconnect, retry, and state continuity incidents in the first implemented slice.

## Scope

This runbook applies when the first-slice interaction path (widget -> runtime -> UI reconciliation) shows failures in reconnect or retry behavior.

## Triage Checklist

1. Confirm release-readiness and conformance reports for current deploy are available.
2. Identify impacted workflow and event types from runtime event stream.
3. Verify `correlation_id` and `request_id` continuity across:
- ingress (`runtime.transport.ingress.v1`),
- service terminal events,
- egress (`runtime.transport.egress.v1`).
4. Check retryability classification for surfaced typed errors.

## Incident Classes

### Transport Interruption / Reconnect Loop

Signals:

- repeated disconnect/reconnect cycles,
- high reconnect attempts per session,
- missing session resume continuity.

Actions:

1. Validate websocket topic migration to `webui:runtime:session:<session_id>:v1` where session context exists.
2. Verify reconnection command issuance and downstream join success/failure events.
3. If reconnect loops persist, trigger rollback criteria from `release_governance_and_rollout.md`.

### Retry Storm / Retry Misclassification

Signals:

- repeated retry attempts with no successful terminal outcomes,
- non-retryable errors incorrectly marked retryable.

Actions:

1. Inspect typed error categories and `retryable` flags.
2. Confirm retry triggers only occur for retryable failures.
3. If retries amplify failure rate, disable rollout and rollback.

### State Continuity Drift

Signals:

- UI state diverges after reconnect/retry,
- session context mismatch between request and response paths.

Actions:

1. Verify runtime context continuity (`session_id`, `correlation_id`, `request_id`).
2. Verify deterministic first-slice UI reconciliation for success and error outcomes.
3. Capture failing payload pairs and open remediation issue.

## Verification Commands

```bash
./scripts/run_conformance.sh --report-only
./scripts/run_release_readiness.sh --report-only
```

Use full validation before reopening rollout:

```bash
./scripts/run_release_readiness.sh
```

## Post-Incident Follow-up

1. Record incident timeline and observable trigger metrics.
2. Add or update conformance scenarios for newly observed failure mode.
3. Add governance debt issue when script/workflow guardrails missed the failure.
4. Seed RFC/spec updates for control-plane or retry-policy clarifications.
