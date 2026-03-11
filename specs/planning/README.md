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
29. [Phase 29 - Canonical Unified-IUR Signal Coercion and Descriptor Hygiene](./phase-29-canonical-unified-iur-signal-coercion-and-descriptor-hygiene.md): normalize canonical signal payload primitives and prevent signal-config leakage in interpreted widget descriptors.
30. [Phase 30 - Canonical Unified-IUR Descriptor Parity and Default Normalization](./phase-30-canonical-unified-iur-descriptor-parity-and-default-normalization.md): normalize default descriptor props so equivalent canonical struct/map inputs produce identical interpreted descriptor trees.
31. [Phase 31 - Canonical Unified-IUR Deep Value Normalization and Style Parity](./phase-31-canonical-unified-iur-deep-value-normalization-and-style-parity.md): normalize nested canonical prop values (including style structs/maps) so equivalent struct/map descriptors remain deeply parity-equivalent.
32. [Phase 32 - Canonical Unified-IUR Nested Default Profile Parity](./phase-32-canonical-unified-iur-nested-default-profile-parity.md): normalize nested default profiles (for example table column defaults) so equivalent struct/map nested descriptors remain parity-equivalent.
33. [Phase 33 - Canonical Unified-IUR Collection Normalization and Set Parity](./phase-33-canonical-unified-iur-collection-normalization-and-set-parity.md): normalize canonical collection values (for example `MapSet`) into deterministic portable shapes so equivalent struct/map descriptors remain parity-equivalent.
34. [Phase 34 - Frontend Toolchain Enforcement and Merge Gates](./phase-34-frontend-toolchain-enforcement-and-merge-gates.md): enforce Elm/Tailwind/DaisyUI frontend validation across local hooks, CI workflows, and conformance coverage.
35. [Phase 35 - Elm Runtime Transport Bridge and Local Roundtrip Harness](./phase-35-elm-runtime-transport-bridge-and-local-roundtrip-harness.md): implement deterministic Elm port-based runtime commands and JS loopback transport simulation for local roundtrip bootstrap flows.
36. [Phase 36 - Frontend Transport Contract Parity and Canonical Event Guardrails](./phase-36-frontend-transport-contract-parity-and-canonical-event-guardrails.md): align Elm/JS harness transport naming with `WebUi.Transport.Naming` and enforce canonical topic/event guardrails via local and CI validation gates.
37. [Phase 37 - Frontend CloudEvent Contract Parity and Envelope Guardrails](./phase-37-frontend-cloudevent-contract-parity-and-envelope-guardrails.md): align Elm/JS harness CloudEvent envelope construction/validation with `WebUi.CloudEvent` required fields and extensions, and enforce parity through local and CI validation gates.
38. [Phase 38 - Frontend Runtime-Context Continuity and Parity Guardrails](./phase-38-frontend-runtime-context-continuity-and-parity-guardrails.md): align Elm/JS harness runtime-context propagation (`WebUi.RuntimeContext`) and enforce deterministic required/optional field parity through local and CI validation gates.
39. [Phase 39 - Frontend Event Catalog Parity and Typed Guardrails](./phase-39-frontend-event-catalog-parity-and-typed-guardrails.md): align Elm/JS harness widget event `type` usage with `WebUi.Events.EventCatalog` and enforce typed invalid-event fail-closed guardrails through local and CI validation gates.
40. [Phase 40 - Frontend Event Payload Contract Parity and Required-Key Guardrails](./phase-40-frontend-event-payload-contract-parity-and-required-key-guardrails.md): align Elm/JS harness widget event `data` payload-key contracts with `WebUi.Events.EventCatalog` required key specs and enforce typed invalid-payload fail-closed guardrails through local and CI validation gates.
41. [Phase 41 - Frontend Event Route Contract Parity and Dispatch-Key Guardrails](./phase-41-frontend-event-route-contract-parity-and-dispatch-key-guardrails.md): align Elm/JS harness widget event route-family mappings and dispatch-key conventions with canonical route contracts and enforce typed invalid-route fail-closed guardrails through local and CI validation gates.
42. [Phase 42 - Frontend Route-Family Continuity and Parity Guardrails](./phase-42-frontend-route-family-continuity-and-parity-guardrails.md): align Elm/JS harness widget event `route_family` payload continuity with canonical event route mappings and enforce typed route-family mismatch fail-closed guardrails through local and CI validation gates.
43. [Phase 43 - Frontend Route-Keys Continuity and Parity Guardrails](./phase-43-frontend-route-keys-continuity-and-parity-guardrails.md): align Elm/JS harness widget event `route_keys` payload continuity with canonical route-key requirements and enforce typed route-keys mismatch fail-closed guardrails through local and CI validation gates.
44. [Phase 44 - Frontend Route-Key Order Continuity and Parity Guardrails](./phase-44-frontend-route-key-order-continuity-and-parity-guardrails.md): align Elm/JS harness widget event `route_keys` ordering continuity with canonical route-key ordering requirements and enforce typed duplicate/order mismatch fail-closed guardrails through local and CI validation gates.
45. [Phase 45 - Frontend Route-Key Completeness and Parity Guardrails](./phase-45-frontend-route-key-completeness-and-parity-guardrails.md): align Elm/JS harness widget event `route_keys` required-key completeness with canonical route-key requirements and enforce typed missing-key fail-closed guardrails through local and CI validation gates.
46. [Phase 46 - Frontend Route-Key Allowlist and Parity Guardrails](./phase-46-frontend-route-key-allowlist-and-parity-guardrails.md): align Elm/JS harness widget event `route_keys` allowlist continuity with canonical route-key requirements and enforce typed unexpected-key fail-closed guardrails through local and CI validation gates.
47. [Phase 47 - Frontend Route-Key Payload-Shape and Parity Guardrails](./phase-47-frontend-route-key-payload-shape-and-parity-guardrails.md): align Elm/JS harness widget event `route_keys` payload-shape continuity with canonical route-key requirements and enforce typed invalid-value fail-closed guardrails through local and CI validation gates.
48. [Phase 48 - Frontend Route-Key Value-Shape and Parity Guardrails](./phase-48-frontend-route-key-value-shape-and-parity-guardrails.md): align Elm/JS harness widget route-key field value-shape continuity with canonical route-key requirements and enforce typed invalid-value fail-closed guardrails through local and CI validation gates.
49. [Phase 49 - Frontend Route-Key Value-Source and Parity Guardrails](./phase-49-frontend-route-key-value-source-and-parity-guardrails.md): align Elm/JS harness widget route-key value-source continuity with canonical route-key source conventions and enforce typed invalid-source fail-closed guardrails through local and CI validation gates.
50. [Phase 50 - Frontend Route-Key Source-Requirements and Parity Guardrails](./phase-50-frontend-route-key-source-requirements-and-parity-guardrails.md): align Elm/JS harness widget route-key source-requirements continuity with canonical route-key source conventions and enforce typed source-requirement drift fail-closed guardrails through local and CI validation gates.
51. [Phase 51 - Frontend Route-Key Source-Keys and Parity Guardrails](./phase-51-frontend-route-key-source-keys-and-parity-guardrails.md): align Elm/JS harness widget route-key source-key continuity with canonical route-key source conventions and enforce typed source-key mismatch fail-closed guardrails through local and CI validation gates.
52. [Phase 52 - Frontend Route-Key Source-Key and Route-Key Parity Guardrails](./phase-52-frontend-route-key-source-key-route-key-parity-guardrails.md): align Elm/JS harness widget route-key source-key continuity with emitted route-key continuity fields and enforce typed source-key-to-route-key mismatch fail-closed guardrails through local and CI validation gates.
53. [Phase 53 - Frontend Route-Key Source-Map and Route-Key Parity Guardrails](./phase-53-frontend-route-key-source-map-route-key-parity-guardrails.md): align Elm/JS harness widget route-key source-map key continuity with emitted route-key continuity fields and enforce typed source-map-to-route-key mismatch fail-closed guardrails through local and CI validation gates.
54. [Phase 54 - Frontend Route-Key Source Triad Parity and Guardrails](./phase-54-frontend-route-key-source-triad-parity-and-guardrails.md): align Elm/JS harness widget route-key source triad continuity (`route_keys`, `route_key_source_keys`, `route_key_sources`) and enforce typed triad parity mismatch fail-closed guardrails through local and CI validation gates.
55. [Phase 55 - Runtime Governance Contract Surface Seeding](./phase-55-runtime-governance-contract-surface-seeding.md): replace policy/turn/scope/replay contract placeholders with deterministic requirement sets and align conformance matrix + ADR requirement-family coverage.
56. [Phase 56 - Remaining Contract and Operations Surface Seeding](./phase-56-remaining-contract-and-operations-surface-seeding.md): replace supervision/eval/prompt-asset and operations placeholders with deterministic requirement/runbook surfaces and align matrix + ADR requirement-family coverage.
57. [Phase 57 - Early Conformance Scenario Doc Seeding](./phase-57-early-conformance-scenario-doc-seeding.md): replace phase 01-09 conformance scenario placeholders with concrete canonical scenario coverage and deterministic validation command references.
58. [Phase 58 - Specs Governance AC Change-Policy Hardening](./phase-58-specs-governance-ac-change-policy-hardening.md): restore AC-bearing component change detection across current specs paths and add regression coverage for fail-closed coupling rules.
59. [Phase 59 - Phase 10 Canonical Scenario Alignment](./phase-59-phase-10-canonical-scenario-alignment.md): align Phase 10 conformance/spec-test scenario labels to canonical SCN identifiers and preserve deterministic release-readiness validation references.

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
