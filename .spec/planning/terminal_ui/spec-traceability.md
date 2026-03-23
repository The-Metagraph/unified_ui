# TerminalUi Spec Traceability Matrix
Generated from the authoritative machine-readable source: [spec-traceability.json](./spec-traceability.json)
This document maps the `terminal_ui` implementation plan to the specs referenced by
the planning index. It makes explicit which requirements are delivered directly
by the `terminal_ui` plan, which ones are inherited from root ecosystem contracts,
and which upstream package specs are treated as input constraints rather than
`terminal_ui`-owned deliverables.
## How To Read This Matrix
- `Primary plan coverage` points at the first task that is expected to satisfy
  the requirement intentionally.
- `Supporting coverage` points at later tasks that broaden, validate, document,
  or harden the same contract.
- `Ownership note` distinguishes direct `terminal_ui` work from inherited or
  upstream constraints.
- Requirement statements remain authoritative in the source spec files; this
  matrix only traces those requirements into plan work.
## Inherited Root Ecosystem Requirements
### `architecture.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.architecture.dsl_authoring_boundary` | `1.1.2` | `6.4.2` | Inherited guardrail; terminal_ui must not absorb DSL ownership. |
| `ecosystem.architecture.iur_exchange_boundary` | `2.3.1` | `3.3.1`, `6.4.2` | Inherited runtime-consumer obligation for canonical IUR. |
| `ecosystem.architecture.renderer_packages_consume_iur` | `2.3.1` | `3.3.1`, `6.4.2` | Inherited renderer-consumer obligation for canonical IUR. |
| `ecosystem.architecture.runtime_libraries_native_surface` | `2.1.1` | `2.1.2`, `3.1.1`, `3.1.2`, `3.2.1`, `3.2.2`, `5.1.1` | Inherited runtime-library obligation for the native terminal surface. |
| `ecosystem.architecture.runtime_libraries_iur_renderer` | `2.3.1` | `3.3.1`, `6.2.2` | Inherited renderer obligation for the canonical IUR entry point. |
| `ecosystem.architecture.shared_transport_contract` | `4.1.1` | `4.2.1`, `4.3.1`, `4.5.1`, `6.2.2` | Inherited cross-package transport obligation. |
### `platform_runtimes.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.platform_runtimes.widget_libraries_independent` | `1.1.2` | `1.4.1`, `6.4.1` | Inherited runtime-boundary guardrail for the native widget library. |
| `ecosystem.platform_runtimes.native_surface_covers_iur` | `2.1.1` | `2.1.2`, `3.1.1`, `3.1.2`, `3.2.1`, `3.2.2`, `3.3.1`, `5.2.1` | Inherited native-surface coverage obligation for canonical IUR. |
| `ecosystem.platform_runtimes.native_surface_usable_without_iur` | `2.1.1` | `2.1.2`, `3.1.1`, `3.2.2`, `5.1.1`, `6.1.1` | Inherited direct-native usability obligation. |
| `ecosystem.platform_runtimes.iur_interpretation` | `2.3.1` | `3.3.1`, `6.2.2` | Inherited canonical-renderer obligation. |
| `ecosystem.platform_runtimes.terminal_ui_targets` | `1.3.1` | `5.2.1`, `5.2.2`, `6.3.1` | Direct inherited terminal_ui target-runtime obligation. |
| `ecosystem.platform_runtimes.terminal_ui_native_runtime` | `2.1.1` | `1.2.1`, `2.3.2`, `5.2.2` | Direct inherited terminal_ui native-runtime obligation. |
### `signal_transport.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.signal_transport.jido_signal_canonical` | `4.1.1` | `4.3.1`, `4.5.1` | Inherited canonical boundary-event obligation. |
| `ecosystem.signal_transport.dsl_event_bindings` | `4.1.1` | `2.3.1`, `6.4.2` | Upstream-authored input; terminal_ui consumes compiled descriptors. |
| `ecosystem.signal_transport.terminal_bridge` | `4.2.1` | `4.2.2`, `4.5.1`, `6.2.2` | Direct inherited terminal_ui transport obligation. |
| `ecosystem.signal_transport.native_signal_models_allowed` | `4.1.2` | `4.2.2`, `4.5.2` | Inherited local-runtime flexibility guardrail. |
| `ecosystem.signal_transport.local_state_not_contract` | `1.2.1` | `4.2.2`, `5.3.2` | Inherited boundary-contract guardrail for local terminal runtime state. |
### Referenced Root Requirements Outside `terminal_ui` Ownership
These referenced root requirements are intentionally not mapped to `terminal_ui`
tasks because they govern other runtime packages:
- `ecosystem.platform_runtimes.elm_ui_runtime_split`
- `ecosystem.platform_runtimes.live_ui_runtime`
- `ecosystem.platform_runtimes.desktop_ui_targets`
- `ecosystem.platform_runtimes.desktop_ui_native_runtime`
- `ecosystem.signal_transport.elm_ui_bridge`
- `ecosystem.signal_transport.live_bridge`
- `ecosystem.signal_transport.desktop_translation`
## Direct `terminal_ui` Spec Requirements
### `package.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `terminal_ui.package.library_identity` | `1.1.1` | `1.5.1`, `6.3.2` | Direct terminal_ui package obligation. |
| `terminal_ui.package.native_runtime_library` | `2.1.1` | `2.2.2`, `3.2.2`, `6.1.1` | Direct terminal_ui package obligation. |
| `terminal_ui.package.iur_renderer_entrypoint` | `2.3.1` | `3.3.1`, `6.3.1` | Direct terminal_ui package obligation. |
| `terminal_ui.package.term_ui_runtime_scope` | `1.2.1` | `1.3.1`, `5.2.1`, `6.3.1` | Direct term_ui-backed runtime-scope obligation. |
| `terminal_ui.package.not_dsl_or_iur_owner` | `1.1.2` | `6.4.2` | Direct terminal_ui boundary obligation. |
| `terminal_ui.package.traceable_to_root_specs` | `6.3.1` | `6.4.1`, `6.4.2` | Direct terminal_ui documentation and governance obligation. |
### `structure.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `terminal_ui.structure.mix_library_layout` | `1.1.1` | `1.5.1` | Direct terminal_ui structure obligation. |
| `terminal_ui.structure.term_ui_adapter_boundary` | `1.1.2` | `1.2.1`, `1.3.1` | Direct runtime-adapter boundary obligation. |
| `terminal_ui.structure.native_widget_module_boundary` | `1.1.2` | `1.4.1`, `2.3.2`, `3.3.1` | Direct native-widget module-boundary obligation. |
| `terminal_ui.structure.transport_translation_modules` | `1.1.2` | `4.1.1`, `4.2.1` | Direct transport-structure obligation. |
| `terminal_ui.structure.capability_and_degradation_modules` | `1.1.2` | `1.3.1`, `5.2.1`, `5.3.1` | Direct capability-and-degradation module boundary obligation. |
| `terminal_ui.structure.no_dsl_or_iur_authorship` | `1.1.2` | `6.4.2` | Direct terminal_ui boundary obligation. |
### `native_widgets.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `terminal_ui.native_widgets.direct_native_surface` | `2.1.1` | `2.1.2`, `3.1.1`, `3.1.2`, `3.2.2`, `5.1.1`, `6.1.1` | Direct native-surface obligation. |
| `terminal_ui.native_widgets.covers_canonical_iur_surface` | `2.3.1` | `3.1.1`, `3.1.2`, `3.2.1`, `3.2.2`, `3.3.1`, `5.2.1` | Direct canonical-parity obligation. |
| `terminal_ui.native_widgets.capability_aware_widget_meaning` | `3.3.2` | `5.2.2`, `5.3.2`, `5.5.2` | Direct cross-capability semantic continuity obligation. |
| `terminal_ui.native_widgets.theme_and_style_surface` | `5.1.1` | `5.1.2`, `5.3.1`, `5.5.1` | Direct styling and theming obligation. |
| `terminal_ui.native_widgets.interaction_surface` | `2.1.2` | `3.2.2`, `4.1.1`, `4.2.2`, `4.4.1` | Direct native-interaction obligation. |
### `runtime.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `terminal_ui.runtime.term_ui_foundation` | `1.2.1` | `1.2.2`, `1.5.1` | Direct shared term_ui runtime obligation. |
| `terminal_ui.runtime.shared_runtime_across_backends` | `1.2.1` | `1.3.1`, `5.2.2` | Direct shared-runtime-across-backends obligation. |
| `terminal_ui.runtime.native_and_iur_entrypoints_share_runtime` | `1.2.1` | `2.3.2`, `3.3.2`, `4.5.2` | Direct runtime-convergence obligation. |
| `terminal_ui.runtime.terminal_lifecycle_and_input` | `1.2.2` | `4.1.2`, `4.2.2`, `5.5.2` | Direct runtime lifecycle and input obligation. |
| `terminal_ui.runtime.capability_variation_bounded` | `1.3.2` | `5.2.2`, `5.3.2` | Direct bounded-capability-variation obligation. |
### `capabilities.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `terminal_ui.capabilities.detect_terminal_capabilities` | `1.3.1` | `1.3.2`, `5.2.1`, `5.3.1` | Direct terminal capability-detection obligation. |
| `terminal_ui.capabilities.backend_selection_and_fallback` | `1.3.1` | `1.3.2`, `5.2.1`, `5.5.2` | Direct backend-selection and fallback obligation. |
| `terminal_ui.capabilities.visual_degradation_policy` | `5.2.1` | `3.2.2`, `5.4.2`, `5.5.1` | Direct visual-degradation obligation. |
| `terminal_ui.capabilities.interaction_alternatives_for_limited_backends` | `3.2.2` | `4.2.2`, `5.2.2`, `5.5.2` | Direct limited-backend interaction-alternatives obligation. |
| `terminal_ui.capabilities.capability_reporting_surface` | `1.4.2` | `5.3.1`, `6.2.1`, `6.3.2` | Direct capability-reporting obligation. |
### `iur_renderer.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `terminal_ui.iur_renderer.accepts_canonical_iur` | `2.3.1` | `3.3.1`, `6.3.1` | Direct renderer obligation. |
| `terminal_ui.iur_renderer.full_construct_coverage` | `3.3.1` | `2.3.1`, `5.2.1`, `6.2.2` | Direct renderer coverage obligation. |
| `terminal_ui.iur_renderer.deterministic_mapping` | `2.3.2` | `3.3.2`, `5.3.2`, `6.2.2` | Direct renderer determinism obligation. |
| `terminal_ui.iur_renderer.meaning_preservation` | `2.3.2` | `3.3.2`, `5.3.2`, `5.5.2` | Direct canonical-meaning obligation. |
| `terminal_ui.iur_renderer.native_widget_reuse` | `2.3.2` | `3.3.1`, `5.3.2` | Direct renderer-stack convergence obligation. |
### `transport.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `terminal_ui.transport.canonical_boundary_events` | `4.1.1` | `4.2.1`, `4.5.1` | Direct transport obligation. |
| `terminal_ui.transport.native_terminal_event_model` | `4.1.2` | `4.2.2`, `4.5.2` | Direct native-event-model obligation. |
| `terminal_ui.transport.backend_input_normalization` | `4.1.2` | `1.3.2`, `4.2.2`, `5.2.2` | Direct backend-input-normalization obligation. |
| `terminal_ui.transport.no_boundary_leakage` | `4.3.1` | `4.1.1`, `4.5.1`, `6.2.2` | Direct contract-hygiene obligation. |
| `terminal_ui.transport.direct_native_usage_allowed` | `4.1.2` | `4.2.2`, `4.4.1`, `4.5.2` | Direct local-native-interaction obligation. |
### `tooling.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `terminal_ui.tooling.reference_examples` | `6.1.1` | `2.4.1`, `3.4.1`, `4.4.1`, `5.4.1` | Direct tooling obligation. |
| `terminal_ui.tooling.preview_and_inspection` | `5.3.1` | `5.3.2`, `6.2.1`, `6.3.2` | Direct tooling obligation. |
| `terminal_ui.tooling.validation_workflow` | `6.2.2` | `4.3.1`, `5.5.1`, `6.5.2` | Direct tooling obligation. |
| `terminal_ui.tooling.backend_compatibility_workflows` | `5.2.1` | `5.2.2`, `6.2.2`, `6.3.1` | Direct tooling obligation for backend and capability workflows. |
| `terminal_ui.tooling.documentation_surface` | `6.3.1` | `6.3.2`, `6.4.1`, `6.5.2` | Direct tooling obligation. |
## Upstream Canonical Input And Authoring Constraints
These specs are referenced by the planning index because they define the
canonical input surface and authored boundary that `terminal_ui` must consume or
respect. They are not implemented by `terminal_ui`, but the plan still needs
deliberate task coverage to preserve compatibility.
### `unified-iur/widgets.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.widgets.input_and_navigation` | `2.1.2` | `2.3.1`, `4.1.1` | Upstream canonical widget scope consumed by terminal_ui. |
| `unified_iur.widgets.overlay_and_feedback` | `3.1.1` | `3.2.2`, `3.3.1`, `4.1.1` | Upstream canonical widget scope consumed by terminal_ui. |
| `unified_iur.widgets.data_and_document_views` | `3.1.1` | `3.3.1`, `3.5.1` | Upstream canonical widget scope consumed by terminal_ui. |
| `unified_iur.widgets.visualization` | `3.1.2` | `3.3.1`, `5.1.1` | Upstream canonical widget scope consumed by terminal_ui. |
| `unified_iur.widgets.operational_views` | `3.1.2` | `3.3.1`, `6.1.1` | Upstream canonical widget scope consumed by terminal_ui. |
| `unified_iur.widgets.widget_semantics_preserved` | `2.3.2` | `3.3.2`, `5.3.2`, `5.5.2` | Upstream parity constraint on renderer behavior. |
### `unified-iur/display_systems.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.display_systems.layout_primitives` | `2.2.1` | `2.3.1`, `3.2.1`, `5.1.1` | Upstream canonical display-system scope consumed by terminal_ui. |
| `unified_iur.display_systems.layering_primitives` | `3.2.2` | `3.3.1`, `4.1.1`, `5.2.1` | Upstream canonical display-system scope consumed by terminal_ui. |
| `unified_iur.display_systems.viewport_and_clipping` | `3.2.1` | `3.3.1`, `3.5.1` | Upstream canonical display-system scope consumed by terminal_ui. |
| `unified_iur.display_systems.canvas_surface` | `3.2.1` | `3.3.1`, `5.2.1` | Upstream canonical display-system scope consumed by terminal_ui. |
| `unified_iur.display_systems.compose_with_widgets` | `3.3.1` | `2.2.1`, `3.2.1`, `3.2.2` | Upstream composition constraint on runtime behavior. |
### `unified-iur/theming.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.theming.theme_structure` | `5.1.2` | `5.3.1`, `5.5.1` | Upstream canonical theming scope consumed by terminal_ui. |
| `unified_iur.theming.color_model` | `5.1.1` | `5.2.1`, `5.5.1` | Upstream canonical theming scope consumed by terminal_ui. |
| `unified_iur.theming.text_style_attributes` | `5.1.1` | `5.3.1`, `5.5.1` | Upstream canonical theming scope consumed by terminal_ui. |
| `unified_iur.theming.semantic_roles` | `5.1.2` | `5.4.1`, `6.1.1` | Upstream canonical theming scope consumed by terminal_ui. |
| `unified_iur.theming.component_variants` | `5.1.1` | `5.1.2`, `5.3.1`, `5.5.1` | Upstream canonical theming scope consumed by terminal_ui. |
| `unified_iur.theming.inheritance_and_overrides` | `5.1.2` | `5.3.2`, `5.5.1` | Upstream canonical theming scope consumed by terminal_ui. |
### `unified-iur/interactions.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.interactions.canonical_event_descriptor_representation` | `4.1.1` | `2.3.1`, `4.2.1`, `4.5.1` | Upstream canonical interaction input consumed by terminal_ui. |
| `unified_iur.interactions.element_binding_attachment` | `2.3.1` | `3.3.1`, `4.2.1` | Upstream canonical interaction input consumed by terminal_ui. |
| `unified_iur.interactions.renderer_independent_payload_mapping` | `4.1.1` | `4.3.1`, `4.5.1` | Upstream canonical interaction hygiene constraint. |
| `unified_iur.interactions.standard_interaction_families` | `4.1.1` | `2.1.2`, `4.4.1`, `4.5.1` | Upstream canonical interaction scope consumed by terminal_ui. |
| `unified_iur.interactions.data_binding_representation` | `2.1.2` | `2.2.1`, `4.2.1`, `4.5.2` | Upstream canonical data-binding input consumed by terminal_ui. |
### `unified-ui/package.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.package.library_identity` | `1.1.2` | `6.4.2` | Upstream ownership guardrail; terminal_ui must stay separate. |
| `unified_ui.package.dsl_boundary_only` | `1.1.2` | `6.4.2` | Upstream ownership guardrail; terminal_ui must not absorb DSL responsibilities. |
| `unified_ui.package.canonical_iur_dependency` | `2.3.1` | `3.3.1`, `6.3.1` | Upstream compiler contract consumed by terminal_ui. |
| `unified_ui.package.standalone_authoring_api` | `1.1.2` | `6.4.2` | Upstream authoring-boundary guardrail. |
| `unified_ui.package.traceable_to_root_specs` | `6.4.1` | `6.4.2` | Upstream governance guardrail reflected in package docs. |
### `unified-ui/signals.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.signals.canonical_descriptor_shape` | `4.1.1` | `2.3.1`, `4.5.1` | Upstream authored-signal input consumed by terminal_ui. |
| `unified_ui.signals.authoring_event_semantics` | `4.1.1` | `4.3.1`, `6.4.2` | Upstream authored-signal input consumed by terminal_ui. |
| `unified_ui.signals.standard_interaction_families` | `4.1.1` | `2.1.2`, `4.4.1`, `4.5.1` | Upstream authored-signal scope consumed by terminal_ui. |
| `unified_ui.signals.validation_and_introspection` | `6.2.1` | `4.3.1`, `6.2.2`, `6.3.2` | Upstream inspection expectations reflected in terminal_ui tooling. |
| `unified_ui.signals.no_runtime_local_event_leakage` | `4.3.1` | `1.2.1`, `6.4.2`, `6.5.2` | Upstream authored-signal hygiene guardrail. |
## Scenario Alignment Pattern
The per-spec scenario clauses are covered through the integration-test sections
at the end of every phase:
- Phase 1: `1.5`
- Phase 2: `2.5`
- Phase 3: `3.5`
- Phase 4: `4.5`
- Phase 5: `5.5`
- Phase 6: `6.5`
This means every requirement in the matrix has both a delivery task and a
phase-closeout verification area in the plan.
