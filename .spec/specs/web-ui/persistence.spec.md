# WebUi Persistence

This subject backfills the current replay-log and replay-baseline persistence
contract implemented by `packages/web_ui`.

```spec-meta
id: web_ui.persistence
kind: subsystem
status: active
summary: Current persistence contract for `packages/web_ui`, including deterministic replay-log helpers, in-memory replay-baseline registry behavior, and frontend runtime replay-control integration.
surface:
  - packages/web_ui/lib/web_ui/persistence/replay_log.ex
  - packages/web_ui/lib/web_ui/persistence/replay_baseline_registry.ex
  - packages/web_ui/lib/web_ui/ui/model.ex
  - packages/web_ui/lib/web_ui/ui/message.ex
  - packages/web_ui/lib/web_ui/ui/runtime.ex
  - packages/web_ui/test/web_ui/persistence
  - packages/web_ui/test/web_ui/ui
  - packages/web_ui/test/web_ui/integration
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: web_ui.persistence.replay_log
  statement: 'The package shall provide the current deterministic replay-log helpers for append, snapshot, compaction, export, restore, compare, verification, checkpoint identifiers, and replay-entry cursor continuity.'
  priority: must
  stability: stable

- id: web_ui.persistence.baseline_registry
  statement: 'The package shall provide the current in-memory replay-baseline registry behavior for upsert, ordering, activation, retention, fetch, and active-baseline lookup.'
  priority: must
  stability: stable

- id: web_ui.persistence.runtime_replay_controls
  statement: 'The frontend runtime shall expose the current replay-control model, message, and update behavior for snapshot, export, compaction, restore, verification, baseline capture, baseline activation, and replay gating state.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/web_ui/lib/web_ui/persistence/replay_log.ex
  covers:
    - web_ui.persistence.replay_log

- kind: source_file
  target: packages/web_ui/lib/web_ui/persistence/replay_baseline_registry.ex
  covers:
    - web_ui.persistence.baseline_registry

- kind: source_file
  target: packages/web_ui/lib/web_ui/ui/model.ex
  covers:
    - web_ui.persistence.runtime_replay_controls

- kind: source_file
  target: packages/web_ui/lib/web_ui/ui/message.ex
  covers:
    - web_ui.persistence.runtime_replay_controls

- kind: source_file
  target: packages/web_ui/lib/web_ui/ui/runtime.ex
  covers:
    - web_ui.persistence.runtime_replay_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/persistence/replay_log_test.exs
  covers:
    - web_ui.persistence.replay_log

- kind: source_file
  target: packages/web_ui/test/web_ui/persistence/replay_baseline_registry_test.exs
  covers:
    - web_ui.persistence.baseline_registry

- kind: source_file
  target: packages/web_ui/test/web_ui/ui/runtime_replay_control_test.exs
  covers:
    - web_ui.persistence.runtime_replay_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_20_persistence_replay_test.exs
  covers:
    - web_ui.persistence.replay_log
    - web_ui.persistence.runtime_replay_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_21_replay_retention_export_test.exs
  covers:
    - web_ui.persistence.replay_log

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_22_replay_restore_apply_test.exs
  covers:
    - web_ui.persistence.replay_log
    - web_ui.persistence.runtime_replay_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_23_replay_verification_test.exs
  covers:
    - web_ui.persistence.replay_log
    - web_ui.persistence.runtime_replay_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_24_replay_verification_gate_test.exs
  covers:
    - web_ui.persistence.runtime_replay_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_25_replay_baseline_gate_test.exs
  covers:
    - web_ui.persistence.baseline_registry
    - web_ui.persistence.runtime_replay_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_26_replay_baseline_registry_test.exs
  covers:
    - web_ui.persistence.baseline_registry
```
