# WebUi Architecture Execution Plan Index

This directory contains a phased implementation plan for executing the current `web_ui` architecture and governance baseline.

The plan aligns to:
- `specs/topology.md`
- `specs/design.md`
- `specs/contracts/*`
- `specs/events/*`
- `specs/conformance/*`
- `rfcs/*`

## Phase Files
1. [Phase 1 - Transport Backbone and CloudEvent Boundary](./phase-01-transport-backbone-and-cloudevent-boundary.md): implement endpoint/router/channel foundations and canonical websocket naming.
2. [Phase 2 - Elm Runtime Bootstrap and UI Loop](./phase-02-elm-runtime-bootstrap-and-ui-loop.md): implement deterministic Elm bootstrap, websocket command flow, and JS interop isolation.
3. [Phase 3 - Runtime Authority Integration and Service Outcomes](./phase-03-runtime-authority-integration-and-service-outcomes.md): implement runtime dispatch, typed result normalization, and context continuity.
4. [Phase 4 - Widget Catalog Parity and Registry Foundation](./phase-04-widget-catalog-parity-and-registry-foundation.md): implement built-in widget parity, descriptors, and deterministic render contracts.
5. [Phase 5 - Widget Event Contracts and Elm Bindings](./phase-05-widget-event-contracts-and-elm-bindings.md): implement event catalog, widget event matrix wiring, and Elm message mappings.
6. [Phase 6 - Custom Widget Extension Governance](./phase-06-custom-widget-extension-governance.md): implement custom widget registration, validation, and built-in override protections.
7. [Phase 7 - Observability and Correlation Baseline](./phase-07-observability-and-correlation-baseline.md): implement event-envelope observability and mandatory metric coverage.
8. [Phase 8 - Conformance Scenario Implementation and Automation](./phase-08-conformance-scenario-implementation-and-automation.md): implement SCN coverage with deterministic conformance automation.
9. [Phase 9 - RFC Intake and Spec Governance Operations](./phase-09-rfc-intake-and-spec-governance-operations.md): operationalize RFC authoring, governance validation, and spec generation workflows.
10. [Phase 10 - First Implemented Slice and Release Readiness](./phase-10-first-implemented-slice-and-release-readiness.md): ship a first end-to-end slice with release gates and production-readiness checks.
11. [Phase 11 - Recovery Replay and Hardening Loop](./phase-11-recovery-replay-and-hardening-loop.md): harden reconnect/retry determinism and observability joinability under failure loops.
12. [Phase 12 - Burst Dispatch Ordering and Replay Fidelity](./phase-12-burst-dispatch-ordering-and-replay-fidelity.md): enforce deterministic ordering for widget burst dispatch and preserve replay sequence integrity.
13. [Phase 13 - Outcome Envelope Hints and UI Reconciliation](./phase-13-outcome-envelope-hints-and-ui-reconciliation.md): expand runtime outcome envelopes with typed UI hints and deterministic reconciliation behavior.
14. [Phase 14 - Release Gate Regression Hardening](./phase-14-release-gate-regression-hardening.md): prevent release-gate false positives/false negatives with deterministic stage markers and regression probes.
15. [Phase 15 - Session Resume Continuity and Replay Semantics](./phase-15-session-resume-continuity-and-replay-semantics.md): enforce resume cursor continuity and deterministic resume acknowledgements across reconnect/replay flows.
16. [Phase 16 - Unified IUR Interpretation and Signal Mapping](./phase-16-unified-iur-interpretation-and-signal-mapping.md): interpret Unified-IUR layout trees and signal hooks into deterministic runtime/event descriptors.
17. [Phase 17 - Policy Authorization and Dispatch Guards](./phase-17-policy-authorization-and-dispatch-guards.md): gate runtime dispatch with deterministic policy authorization checks and fail-closed outcomes.
18. [Phase 18 - Turn Execution Determinism and State Reconciliation](./phase-18-turn-execution-determinism-and-state-reconciliation.md): propagate deterministic turn IDs through dispatch and reconcile turn completion state across runtime outcomes.
19. [Phase 19 - Scope Resolution and Context Propagation](./phase-19-scope-resolution-and-context-propagation.md): resolve and propagate deterministic scope metadata through runtime dispatch with fail-closed scope-policy checks.
20. [Phase 20 - Persistence Replay Determinism and Checkpointing](./phase-20-persistence-replay-determinism-and-checkpointing.md): track deterministic replay cursors/checkpoints across dispatch and reconciliation flows.
21. [Phase 21 - Replay Retention and Export Controls](./phase-21-replay-retention-and-export-controls.md): provide deterministic replay snapshot/export and retention controls for runtime recovery diagnostics.
22. [Phase 22 - Replay Restore and Apply Continuity](./phase-22-replay-restore-and-apply-continuity.md): restore replay state from exported payloads and preserve deterministic cursor continuity for subsequent dispatches.
23. [Phase 23 - Replay Drift Detection and Verification](./phase-23-replay-drift-detection-and-verification.md): detect deterministic replay drift between runtime logs and expected replay exports.
24. [Phase 24 - Replay Verification Gate Policies](./phase-24-replay-verification-gate-policies.md): evaluate replay verification results against deterministic gate policies for release diagnostics.
25. [Phase 25 - Replay Baseline Capture and Gate Continuity](./phase-25-replay-baseline-capture-and-gate-continuity.md): capture deterministic replay baselines and evaluate current replay state against baseline gate policies.
26. [Phase 26 - Replay Baseline Registry and Selection Continuity](./phase-26-replay-baseline-registry-and-selection-continuity.md): persist deterministic baseline registries with retention controls and active-baseline selection for gate evaluation.
27. [Phase 27 - Canonical Unified-IUR Dependency and Contract Alignment](./phase-27-canonical-unified-iur-dependency-and-contract-alignment.md): consume canonical Unified-IUR schema authority from `unified_iur` with explicit runtime, contract, and conformance guardrails.
28. [Phase 28 - Canonical Unified-IUR Extended Signal and Container Mapping](./phase-28-canonical-unified-iur-extended-signal-and-container-mapping.md): map canonical menu/table/tabs/tree signals and container child descriptors into deterministic runtime events.

## Shared Conventions
- Numbering:
  - Phases: `N`
  - Sections: `N.M`
  - Tasks: `N.M.K`
  - Subtasks: `N.M.K.L`
- Tracking:
  - Every phase, section, task, and subtask uses Markdown checkboxes (`[ ]`).
- Description requirement:
  - Every phase, section, and task starts with a short description paragraph.
- Integration-test requirement:
  - Each phase ends with a final integration-testing section.

## Shared Assumptions and Defaults
- `WebUi.*` naming is canonical for runtime modules.
- CloudEvents-shaped envelopes are the canonical transport payload.
- Runtime/domain state authority remains server-side.
- Elm is the canonical deterministic UI runtime.
- Widget baseline parity with `term_ui` is normative for built-ins.
- Governance and conformance docs are mandatory before merge.
