# Application Authority

This subject defines the authoritative application boundary for applications
that coordinate canonical UI meaning across one or more ecosystem runtimes.

```spec-meta
id: ecosystem.application_authority
kind: architecture
status: active
summary: Architecture contract for application-authoritative UI layers that emit canonical IUR to runtimes and handle canonical CloudEvents-compatible signals from those runtimes.
surface:
  - packages/unified-ui
  - packages/unified_iur
  - packages/live_ui
  - packages/elm_ui
  - packages/desktop_ui
  - packages/terminal_ui
  - .spec/specs/application_authority.spec.md
  - .spec/specs/architecture.spec.md
  - .spec/specs/platform_runtimes.spec.md
  - .spec/specs/signal_transport.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.elm_ui_naming
```

## Requirements

```spec-requirements
- id: ecosystem.application_authority.authoritative_ui_representation
  statement: The ecosystem shall support an application-authoritative UI layer that owns authoritative UI meaning, workflow state, and cross-runtime coordination above renderer-local realization concerns.
  priority: must
  stability: stable

- id: ecosystem.application_authority.canonical_iur_emission
  statement: An application-authoritative UI layer shall emit canonical `unified_iur` as the renderer-facing UI output rather than renderer-specific widget trees, transport-local view models, or runtime-local callback structures.
  priority: must
  stability: stable

- id: ecosystem.application_authority.runtime_or_session_specific_views
  statement: An application-authoritative UI layer may emit distinct canonical `unified_iur` views for different runtimes, capability profiles, or sessions when needed, but those views shall remain canonical rather than falling back to renderer-specific output formats.
  priority: must
  stability: stable

- id: ecosystem.application_authority.canonical_signal_roundtrip
  statement: An application-authoritative UI layer shall receive and emit cross-runtime UI interactions as `Jido.Signal` values using CloudEvents-compatible semantics rather than renderer-local event names or runtime-local signal envelopes.
  priority: must
  stability: stable

- id: ecosystem.application_authority.one_authority_many_runtimes
  statement: One application-authoritative UI layer may coordinate `live_ui`, `elm_ui`, `desktop_ui`, and `terminal_ui` frontends for the same workflow or domain state while preserving one canonical boundary contract across those runtimes.
  priority: must
  stability: stable

- id: ecosystem.application_authority.runtime_local_state_subordinate
  statement: Runtime-local rendering state, bounded frontend-local state, and platform-local realization details may exist within each runtime, but when UI state or interactions cross the ecosystem boundary they shall remain subordinate to the application-authoritative representation and canonical contracts.
  priority: must
  stability: stable

- id: ecosystem.application_authority.runtimes_remain_native
  statement: Application-authoritative coordination shall not erase runtime-library responsibilities for native rendering, native interaction models, platform adaptation, or capability-aware degradation inside each runtime package.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/application_authority.spec.md
  covers:
    - ecosystem.application_authority.authoritative_ui_representation
    - ecosystem.application_authority.canonical_iur_emission
    - ecosystem.application_authority.runtime_or_session_specific_views
    - ecosystem.application_authority.canonical_signal_roundtrip
    - ecosystem.application_authority.one_authority_many_runtimes
    - ecosystem.application_authority.runtime_local_state_subordinate
    - ecosystem.application_authority.runtimes_remain_native
```
