# Fault Recovery and Determinism Hardening

## Purpose

Seed post-release conformance hardening for failure recovery, deterministic replay, and observability joinability.

## Telemetry Review Checklist

Review the following by contract/scenario family after each release window:

### Transport and Service (`REQ-SVC-*`, `SCN-001`..`SCN-006`)

1. Decode/encode failures trend (`webui_event_decode_error_total`, `webui_event_encode_error_total`).
2. Typed-error category distribution (`validation`, `protocol`, `dependency`, `timeout`, `internal`).
3. Correlation continuity from ingress -> runtime -> egress.

### Widget and UI Runtime (`REQ-WGT-*`, `SCN-007`..`SCN-012`)

1. Widget-event validation rejection rates by event type.
2. Retry/cancel path usage frequency and completion rates.
3. Reconnect/session-resume success ratio.

### Observability (`REQ-OBS-*`, `SCN-006`)

1. Runtime event envelope conformance failures.
2. Event/metric joinability diagnostics findings.
3. Label policy violations and rejected metrics.

## Prioritization Criteria

Each candidate hardening item SHOULD be scored using:

1. User impact (blocked workflow, degraded UX, or silent corruption risk).
2. Frequency (how often issue occurs in release window).
3. Detectability (how quickly issue is visible in telemetry).
4. Recovery complexity (manual intervention required vs automatic recovery).

Suggested priority bands:

- `P0`: High impact + high frequency OR data/authority safety risk.
- `P1`: High impact but bounded frequency, or repeated operational toil.
- `P2`: Medium impact with deterministic workaround.
- `P3`: Low impact or cosmetic-only follow-up.

## Conformance Additions Backlog

Candidate scenarios to add after initial release learning:

1. Session-resume replay idempotency for repeated reconnect loops.
2. Retry storm containment with deterministic backoff/cancel transitions.
3. Multi-event burst ordering guarantees under concurrent widget dispatch.
4. Joinability resilience when observability emitter rejects invalid labels.
5. First-slice terminal event completeness on timeout + retry + cancel chains.

## Review Cadence

1. Daily during first 7 days after release.
2. Weekly after initial stabilization window.
3. Mandatory review before next major phase planning starts.
