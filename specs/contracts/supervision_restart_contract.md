# Supervision Restart Contract

This contract defines deterministic reconnect, retry, cancel, and session-resume restart semantics.

## Covered Runtime Modules

- `WebUi.Ui.Runtime`
- `WebUi.Transport.Naming`

## Requirement Set

- `REQ-SUP-001`: Transport disconnect handling MUST transition runtime into reconnecting state with deterministic recovery-state updates.
- `REQ-SUP-002`: Session-aware reconnect operations MUST target canonical session resume topics (`webui:runtime:session:<session_id>:v1`).
- `REQ-SUP-003`: Repeated disconnects with equivalent resume topic + cursor MUST dedupe reconnect join command emission.
- `REQ-SUP-004`: Resume cursors MUST derive deterministically from dispatch sequence and MUST be attached to reconnect join payloads.
- `REQ-SUP-005`: Resume acknowledgements MUST clear pending resume cursor state and persist deterministic last-resumed diagnostics.
- `REQ-SUP-006`: Retry requests MUST apply bounded deterministic backoff progression and MUST fail closed at exhaustion.
- `REQ-SUP-007`: Retry replay MUST enqueue the last retryable outbound command without command-shape mutation.
- `REQ-SUP-008`: Cancel requests MUST clear retry-pending state, reset retry counters/backoff, and converge UI slice state to `:cancelled`.
- `REQ-SUP-009`: Timeout/retry/cancel chains MUST converge to deterministic terminal UI and recovery state for equivalent flows.
- `REQ-SUP-010`: Restart and recovery transitions MUST emit deterministic notices/history markers for reconnect, retry, exhaustion, cancel, and resume acknowledgement paths.

## Types

### RecoveryState

```text
RecoveryState {
  reconnect_attempts: non_neg_integer,
  session_resume_topic?: string | nil,
  session_resume_cursor?: non_neg_integer | nil,
  last_resumed_sequence?: non_neg_integer | nil,
  retry_pending?: boolean,
  retry_attempts: non_neg_integer,
  retry_backoff_ms?: non_neg_integer | nil,
  last_command?: map | nil
}
```

### ReconnectJoinPayload

```text
ReconnectJoinPayload {
  session_id: string,
  resume_from_sequence: non_neg_integer
}
```

### RetryPolicy

```text
RetryPolicy {
  max_attempts: pos_integer,
  backoff_schedule_ms: [pos_integer]
}
```

## Canonical Restart Rules

1. Equivalent reconnect/disconnect sequences MUST produce equivalent dedupe outcomes.
2. Equivalent retry sequences MUST produce equivalent backoff progressions and exhaustion outcomes.
3. Exhausted retries MUST emit typed `ui.retry.exhausted` errors and MUST stop replay command emission.
4. Resume acknowledgement notices MUST use canonical `resume:ack:<sequence>` diagnostics.

## Conformance Mapping

- `SCN-013`: reconnect-loop idempotency and session-resume topic continuity.
- `SCN-014`: bounded retry storm containment and deterministic backoff/exhaustion behavior.
- `SCN-016`: timeout/retry/cancel terminal-state determinism.
- `SCN-020`: resume cursor continuity and resume acknowledgement diagnostics.

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
