# Codex Comprehensive Plan and Codebase Audit

Date: 2026-02-18
Scope audited: `/Users/Pascal/code/unified/unified-ui`

## Executive Summary

The codebase is significantly ahead of the original planning checklists in Phases 2-4.
Core DSL entities, adapters for terminal/desktop/web, event modules, table/data-viz/navigation widgets, and a large test suite are already present.

The main remaining work is no longer basic scaffolding. It is hardening and refinement:
- deepen adapter update performance beyond root-level diff checks (subtree incremental patching)
- complete documentation terminology alignment (`renderers/*` -> `adapters/*`) across legacy planning artifacts
- continue production quality improvements (dialyzer warning reduction, accessibility/keyboard parity contracts)

## Verification Method

- Static code audit of modules and tests.
- Initial audit run did not include runtime verification because `mix` was unavailable in that environment.

## Progress Update (2026-02-20)

- Track C.1 complete: adapter `update/3` paths are now diff-aware and skip no-op updates.
- Track C.2 complete: coordinator now supports platform event normalization and explicit target routing contracts.
- Track C.3 in progress: planning/architecture docs are being updated to consistently use `adapters/*` naming.

## Progress Update (2026-03-10)

- Track C.2 completed end-to-end agent integration: `UnifiedUi.Agent.Server` now subscribes to component signal topics and processes `{:unified_ui_signal, %Jido.Signal{}}` bus messages.
- Components expose a deterministic topic via `UnifiedUi.Agent.component_signal_topic/1`, enabling coordinator topic routing to drive component updates.
- Coordinator dispatch contracts now include direct component targets (`{:component, component_id}`), so normalized platform events can route to agents without requiring explicit topic wiring.
- Coordinator now also treats unmatched atom targets as component IDs, preserving process-name routing while adding zero-config component dispatch ergonomics.
- Coordinator concurrent rendering now preserves per-platform timeout and task-exit results (`%{platform => {:error, :timeout | {:task_exit, reason}}}`) instead of collapsing failures under a generic `:error` map key.

## Progress Update (2026-03-11)

- Planning/audit status has been realigned with implementation reality: foundational runtime agent integration, advanced widget families, guide coverage, and `mix unified_ui.*` tooling are now tracked as completed.
- Track C remains focused on adapter runtime depth (subtree incremental updates) and final planning terminology cleanup.
- Terminal adapter `update/3` now applies recursive nested VBox/HBox subtree patching for stable layout signatures/child counts, reusing unchanged grandchildren and only re-rendering changed nodes.
- Desktop adapter `update/3` now applies recursive nested VBox/HBox subtree patching for stable layout signatures/child counts, reusing unchanged grandchildren and only re-rendering changed nodes.
- Web adapter `update/3` now applies recursive nested VBox/HBox subtree patching for stable layout signatures/child counts, reusing unchanged grandchildren and only re-rendering changed nodes.

## Audit Findings by Phase

### Phase 1 (Foundation) - Complete with follow-up maturity work

Completed evidence:
- Dependencies include Spark/Jido/JidoSignal/TermUi and extracted `unified_iur` package (`mix.exs` lines 28-32).
- DSL extension is defined with sections, transformers, and verifiers (`lib/unified_ui/dsl/extension.ex` lines 267-274).
- Signal helpers are implemented (`lib/unified_ui/signals.ex` lines 69-213).
- Elm behavior and base transformers exist (`lib/unified_ui/elm_architecture.ex`; `lib/unified_ui/dsl/transformers/*.ex`).

Gaps:
- No blocking foundation gaps remain; runtime component agents, supervision wiring, and canonical DSL section modules are implemented.

### Phase 2 (Core Widgets and Layouts) - Substantially complete

Completed evidence:
- Core widget entities (`button`, `text`, `label`, `text_input`) implemented (`lib/unified_ui/dsl/entities/widgets.ex` lines 239-248).
- Core layout entities (`vbox`, `hbox`) implemented (`lib/unified_ui/dsl/entities/layouts.ex` lines 148-151).
- Form/state/style helpers implemented (`lib/unified_ui/dsl/form_helpers.ex` lines 109-459; `lib/unified_ui/dsl/state_helpers.ex` lines 49-136; `lib/unified_ui/dsl/style_resolver.ex` lines 87-269).
- IUR builder exists (`lib/unified_ui/iur/builder.ex` line 85 onward).
- Verifiers exist for unique IDs/layout/signal/style/state (`lib/unified_ui/dsl/verifiers.ex`).

Gaps:
- `UpdateTransformer` still relies on runtime route lookup/default handlers rather than fully generated clause sets per DSL declaration.

### Phase 3 (Renderer Implementations) - Substantially complete

Completed evidence:
- Shared renderer behavior callbacks (`lib/unified_ui/adapters/protocol.ex` lines 1, 116, 150, 173).
- Shared traversal/find/style utilities (`lib/unified_ui/adapters/shared.ex` lines 82, 113, 172, 299).
- Terminal/Desktop/Web adapters implement behavior (`lib/unified_ui/adapters/terminal/renderer.ex` lines 49, 58, 71, 78; `lib/unified_ui/adapters/desktop/renderer.ex` lines 60, 69, 82, 89; `lib/unified_ui/adapters/web/renderer.ex` lines 56, 65, 78, 85).
- Terminal/Desktop/Web event modules implemented (`lib/unified_ui/adapters/terminal/events.ex` lines 77, 124; `lib/unified_ui/adapters/desktop/events.ex` lines 104, 156; `lib/unified_ui/adapters/web/events.ex` lines 104, 156).
- Multi-platform coordinator implemented (`lib/unified_ui/adapters/coordinator.ex`).

Gaps:
- Subtree-level incremental patching is now only partially implemented (terminal + desktop + web nested VBox/HBox subtree patching complete); cross-adapter subtree patching by element ID is not implemented yet.
- Planning terminology alignment is still in progress; legacy phase artifacts still reference `renderers/*` paths.

### Phase 4 (Advanced Features and Styling) - Substantially complete

Completed evidence:
- Data-viz entities exist (`lib/unified_ui/dsl/entities/data_viz.ex` lines 349-355).
- Table entities and sorting logic exist (`lib/unified_ui/dsl/entities/tables.ex` lines 252-254; `lib/unified_ui/table/sort.ex`).
- Navigation entities exist (`lib/unified_ui/dsl/entities/navigation.ex` lines 586-591).
- Render support for data-viz/table/navigation exists in all three adapters (terminal/desktop/web renderer modules).
- Dialog/alert/toast, pick_list/form_builder, viewport/split_pane, and specialized/monitoring widgets are implemented with adapter conversions and tests.

Gaps:
- Accessibility and keyboard interaction parity contracts still need explicit cross-platform documentation and dedicated parity tests.

### Phase 5 (Testing, Docs, Tooling) - Substantially complete

Completed evidence:
- Broad test surface exists, including phase integration tests:
  - `test/unified_ui/integration/phase_2_test.exs`
  - `test/unified_ui/integration/phase_3_test.exs`
  - `test/unified_ui/integration/phase_4_test.exs`
- Adapter, entity, transformer tests are present under `test/unified_ui/adapters`, `test/unified_ui/dsl/entities`, `test/unified_ui/dsl/transformers`.
- CI runs lint/test/bench workflows, with coverage threshold configured via `mix.exs` `test_coverage`.
- Guides referenced in docs config are present under `guides/`.
- `mix unified_ui.*` tasks are implemented (`new`, `gen.*`, `preview`, `test`, `format`, `bench`, `perf.check`, `stats`).
- Root README is fully populated and no longer placeholder content.

Gaps:
- Dialyzer warning baseline is still high and should be reduced over time to improve signal quality for CI/runtime regressions.

## Comprehensive Delivery Plan (Rebased on Current Reality)

### Track A - Foundation Hardening (highest priority)

1. Implement runtime integration for components as agents.
- Add `UnifiedUi.Agent` API and Jido agent lifecycle hooks.
- Add registry/supervisor children in `UnifiedUi.Application`.
- Exit criteria: components can be started/stopped and receive routed signals end-to-end.
Status: complete.

2. Complete transformer maturity.
- Update `UpdateTransformer` to derive handler clauses from DSL entities instead of generic fallbacks.
- Complete state interpolation/state reference validation pipeline.
- Exit criteria: DSL declarations directly drive generated `update/2` and consistent state wiring.
Status: in progress.

3. Remove/align stale DSL section modules.
- Either delete unused placeholder section modules or wire them as authoritative sources.
- Exit criteria: one canonical DSL definition path; no "future phase" placeholders contradicting implementation.
Status: complete.

### Track B - DSL-to-IUR Completeness

1. Extend `UnifiedUi.IUR.Builder` for all existing DSL entities.
- Add `gauge/sparkline/bar_chart/line_chart/table` builder dispatch and constructors.
- Add regression tests for full DSL -> IUR conversion, not only direct IUR struct tests.
- Exit criteria: every entity in `extension.ex` is buildable from DSL state.
Status: complete.

2. Validate full build path with complex nested examples.
- Add integration tests that define modules with the DSL and assert resulting IUR shape.
- Exit criteria: one golden example per major widget family.
Status: complete.

### Track C - Renderer Runtime Hardening

1. Move from rerender to diff-aware update.
- Add element-ID matching and incremental update logic where possible.
- Exit criteria: `update/3` applies structural diff, no full rerender default for unchanged subtrees.
Status: root-level diff-aware updates complete; terminal + desktop + web nested VBox/HBox subtree patching is complete; cross-adapter element-ID subtree patching remains.

2. Strengthen event dispatch path.
- Complete bus dispatch wiring and target routing contracts.
- Exit criteria: platform event -> normalized signal -> target handler integration tests pass.
Status: complete for coordinator normalization/routing, topic fanout, and component agent integration.

3. Align naming and architecture docs.
- Update planning docs from "renderers" to actual "adapters" naming or rename code consistently.
- Exit criteria: docs and code terminology match.
Status: in progress.

### Track D - Finish Remaining Phase 4 Features

1. Implement missing advanced widgets and render support.
- Dialog/alert/toast.
- Pick list/form builder.
- Viewport/split pane.
- Exit criteria: entity + IUR + terminal/desktop/web render + events + tests for each widget family.
Status: complete for core planned advanced widget families.

2. Add accessibility and keyboard contracts where relevant (web/desktop especially).
- Exit criteria: documented keyboard interactions and event parity tests.
Status: in progress.

### Track E - Production Readiness (Phase 5)

1. Test execution and CI gates.
- Add CI job with `mix test`, coverage reporting, and threshold gate.
- Exit criteria: reproducible CI pass and stated coverage target.
Status: complete.

2. Documentation and guides.
- Fix missing `guides/` references or create the files.
- Add API docs configuration dependencies and generate docs in CI.
- Replace placeholder root README content.
- Exit criteria: docs build cleanly and published artifact path is defined.
Status: largely complete; ongoing updates are content quality improvements.

3. Developer tooling.
- Add `mix unified_ui.*` tasks planned for scaffolding/generation/preview.
- Exit criteria: tasks available via `mix help` and covered by tests.
Status: complete.

4. Performance and benchmark baseline.
- Add benchmark scripts and baseline targets.
- Exit criteria: measurable baseline committed and tracked.
Status: complete.

## Recommended Execution Order

1. Track C.1 (subtree-level adapter incremental updates)
2. Track C.3 (complete planning terminology alignment to adapters)
3. Track D.2 (accessibility and keyboard parity contracts)
4. Track A.2 (transformer clause-generation maturity)
5. Track E residual hardening (dialyzer warning reduction)

Rationale: foundational/platform breadth work is already landed; remaining value is in runtime depth, docs coherence, and quality gates.
