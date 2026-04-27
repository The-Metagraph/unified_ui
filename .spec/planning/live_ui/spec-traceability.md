# LiveUi Spec Traceability Matrix
Generated from the authoritative machine-readable source: [spec-traceability.json](./spec-traceability.json)
This document maps the `live_ui` implementation plan to the specs referenced by
the planning index. It makes explicit which requirements are delivered directly
by the `live_ui` plan, which ones are inherited from root ecosystem contracts,
and which upstream package specs are treated as input constraints rather than
`live_ui`-owned deliverables.
## How To Read This Matrix
- `Primary plan coverage` points at the first task that is expected to satisfy
  the requirement intentionally.
- `Supporting coverage` points at later tasks that broaden, validate, document,
  or harden the same contract.
- `Ownership note` distinguishes direct `live_ui` work from inherited or
  upstream constraints.
- Requirement statements remain authoritative in the source spec files; this
  matrix only traces those requirements into plan work.
## Inherited Root Ecosystem Requirements
### `architecture.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.architecture.dsl_authoring_boundary` | `1.1.2` | `6.4.2` | Inherited guardrail; live_ui must not absorb DSL ownership. |
| `ecosystem.architecture.iur_exchange_boundary` | `2.3.2` | `3.3.1`, `6.4.2` | Inherited runtime-consumer obligation. |
| `ecosystem.architecture.renderer_packages_consume_iur` | `2.3.2` | `3.3.1`, `6.4.2` | Inherited renderer-consumer obligation. |
| `ecosystem.architecture.runtime_libraries_native_surface` | `2.1.1` | `2.2.1`, `2.2.2`, `3.1.1`, `3.1.2`, `3.2.1`, `3.2.2`, `5.1.1`, `5.1.2` | Inherited runtime-library obligation. |
| `ecosystem.architecture.runtime_libraries_iur_renderer` | `2.3.2` | `3.3.1`, `6.2.2` | Inherited renderer obligation. |
| `ecosystem.architecture.shared_transport_contract` | `4.1.1` | `4.2.1`, `4.3.1`, `4.5.1`, `6.2.2` | Inherited cross-package transport obligation. |
### `platform_runtimes.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.platform_runtimes.widget_libraries_independent` | `1.1.2` | `1.4.1`, `6.4.1` | Inherited runtime-boundary guardrail. |
| `ecosystem.platform_runtimes.native_surface_covers_iur` | `2.1.1` | `2.2.1`, `2.2.2`, `3.1.1`, `3.1.2`, `3.2.1`, `3.2.2`, `3.3.1`, `5.1.1`, `5.1.2` | Inherited native-surface coverage obligation. |
| `ecosystem.platform_runtimes.native_surface_usable_without_iur` | `2.1.1` | `2.2.1`, `2.2.2`, `3.1.1`, `3.2.1`, `6.1.1` | Inherited direct-native usability obligation. |
| `ecosystem.platform_runtimes.iur_interpretation` | `2.3.2` | `3.3.1`, `6.2.2` | Inherited canonical-renderer obligation. |
| `ecosystem.platform_runtimes.live_ui_runtime` | `1.3.1` | `1.3.2`, `4.2.1`, `4.2.2`, `5.3.2` | Direct inherited live_ui runtime-shape obligation. |
### `signal_transport.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.signal_transport.jido_signal_canonical` | `4.1.1` | `4.3.1`, `4.5.1` | Inherited canonical boundary-event obligation. |
| `ecosystem.signal_transport.dsl_event_bindings` | `4.1.1` | `2.3.2`, `6.4.2` | Upstream-authored input; live_ui consumes compiled descriptors. |
| `ecosystem.signal_transport.live_bridge` | `4.2.1` | `4.2.2`, `4.5.1`, `6.2.2` | Direct inherited live_ui transport obligation. |
| `ecosystem.signal_transport.native_signal_models_allowed` | `4.1.2` | `4.2.2`, `4.5.1` | Inherited local-runtime flexibility guardrail. |
| `ecosystem.signal_transport.local_state_not_contract` | `1.3.2` | `4.2.2`, `4.5.2`, `5.3.2` | Inherited boundary-contract guardrail. |
### Referenced Root Requirements Outside `live_ui` Ownership
These referenced root requirements are intentionally not mapped to `live_ui`
tasks because they govern other runtime packages:
- `ecosystem.platform_runtimes.elm_ui_runtime_split`
- `ecosystem.platform_runtimes.desktop_ui_targets`
- `ecosystem.platform_runtimes.desktop_ui_native_runtime`
- `ecosystem.signal_transport.elm_ui_bridge`
- `ecosystem.signal_transport.desktop_translation`
## Direct `live_ui` Spec Requirements
### `package.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `live_ui.package.library_identity` | `1.1.1` | `1.5.1`, `6.3.2` | Direct live_ui package obligation. |
| `live_ui.package.native_runtime_library` | `2.1.1` | `2.2.1`, `2.2.2`, `3.1.1`, `3.2.1`, `6.1.1` | Direct live_ui package obligation. |
| `live_ui.package.iur_renderer_entrypoint` | `2.3.2` | `3.3.1`, `6.3.1`, `6.4.1` | Direct live_ui package obligation. |
| `live_ui.package.not_dsl_or_iur_owner` | `1.1.2` | `6.4.2` | Direct live_ui boundary obligation. |
| `live_ui.package.traceable_to_root_specs` | `6.4.1` | `6.4.2`, `6.3.2` | Direct live_ui documentation and governance obligation. |
| `live_ui.package.widget_component_library_surface` | `11.1` | `11.1.1` | Phase 11: Native surface is a mountable LiveComponent-oriented widget library. |
| `live_ui.package.focused_example_specialization` | `18.1.1` | `18.1.2`, `18.2.1`, `18.3.2` | Phase 18: Package examples align one-for-one with the repository focused example inventory and specialize it for native live_ui review. |
### `structure.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `live_ui.structure.mix_library_layout` | `1.1.1` | `1.3.1`, `1.5.1` | Direct live_ui structure obligation. |
| `live_ui.structure.native_widget_module_boundary` | `1.1.2` | `1.2.1`, `2.3.2`, `3.3.1` | Direct live_ui structure obligation. |
| `live_ui.structure.liveview_runtime_modules` | `1.3.1` | `1.3.2`, `4.2.1`, `5.3.1` | Direct live_ui runtime-structure obligation. |
| `live_ui.structure.hooks_are_isolated` | `1.3.2` | `3.2.2`, `4.2.2`, `6.4.1` | Direct browser-bridge isolation obligation. |
| `live_ui.structure.transport_translation_modules` | `1.1.2` | `4.1.1`, `4.2.1`, `4.3.1` | Direct live_ui transport-structure obligation. |
| `live_ui.structure.no_dsl_or_iur_authorship` | `1.1.2` | `6.4.2` | Direct live_ui boundary obligation. |
| `live_ui.structure.widget_livecomponent_modules` | `11.1` | `11.1.1` | Phase 11: Widget LiveComponent modules for native widget surface. |
| `live_ui.structure.screen_and_renderer_target_widget_boundaries` | `11.2` | `11.2.1` | Phase 11: Screen and renderer compose widget component instances. |
| `live_ui.structure.helper_wrappers_remain_thin` | `11.3` | `11.3.1` | Phase 11: Helper wrappers remain thin facades over widget components. |
### `native_widgets.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `live_ui.native_widgets.direct_native_surface` | `2.1.1` | `2.2.1`, `2.2.2`, `3.1.1`, `3.1.2`, `3.2.1`, `3.2.2`, `5.1.1`, `6.1.1` | Direct native-surface obligation. |
| `live_ui.native_widgets.covers_canonical_iur_surface` | `2.3.2` | `3.1.1`, `3.1.2`, `3.2.1`, `3.2.2`, `3.3.1`, `5.1.1`, `5.1.2` | Direct canonical-parity obligation. |
| `live_ui.native_widgets.liveview_native_composition` | `1.2.2` | `2.2.1`, `2.3.2`, `5.3.2` | Direct LiveView-native composition obligation. |
| `live_ui.native_widgets.theme_and_style_surface` | `5.1.1` | `5.1.2`, `5.2.1`, `5.2.1`, `5.5.1` | Direct styling and theming obligation. |
| `live_ui.native_widgets.interaction_surface` | `2.2.1` | `2.2.2`, `3.2.1`, `4.1.1`, `4.2.1`, `4.4.1` | Direct native-interaction obligation. |
| `live_ui.native_widgets.mountable_widget_components` | `11.1` | `11.1.1` | Phase 11: Each native widget has mountable LiveComponent boundary. |
| `live_ui.native_widgets.helper_apis_delegate_to_components` | `11.3` | `11.3.1` | Phase 11: Helper APIs delegate to widget component boundary. |
| `live_ui.native_widgets.bounded_widget_state` | `11.2` | `11.2.2` | Phase 11: Widget components may own bounded local UI state. |
### `runtime.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `live_ui.runtime.server_authoritative_model` | `1.3.1` | `4.2.1`, `4.5.2`, `5.3.1` | Direct server-authority obligation. |
| `live_ui.runtime.liveview_component_execution` | `1.2.1` | `1.2.2`, `1.3.1`, `2.5.1` | Direct LiveView-runtime execution obligation. |
| `live_ui.runtime.hooks_only_where_necessary` | `1.3.2` | `3.2.2`, `4.2.2`, `4.5.2` | Direct bounded-hook obligation. |
| `live_ui.runtime.native_and_iur_entrypoints_share_runtime` | `1.3.1` | `2.3.2`, `3.3.1`, `4.5.2` | Direct runtime-convergence obligation. |
| `live_ui.runtime.state_and_render_continuity` | `2.3.2` | `3.3.1`, `5.3.2`, `5.5.2` | Direct continuity obligation. |
| `live_ui.runtime.widget_component_local_state` | `11.2` | `11.2.2` | Phase 11: Widget components may own bounded local UI lifecycle state. |
### `iur_renderer.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `live_ui.iur_renderer.accepts_canonical_iur` | `2.3.2` | `3.3.1`, `6.4.1` | Direct renderer obligation. |
| `live_ui.iur_renderer.full_construct_coverage` | `3.3.1` | `2.3.2`, `5.2.1`, `5.2.1`, `6.2.2` | Direct renderer coverage obligation. |
| `live_ui.iur_renderer.deterministic_mapping` | `2.3.2` | `3.3.1`, `5.2.1`, `5.3.2`, `6.2.2` | Direct renderer determinism obligation. |
| `live_ui.iur_renderer.meaning_preservation` | `2.3.2` | `3.3.1`, `4.5.1`, `5.3.2`, `5.5.2` | Direct canonical-meaning obligation. |
| `live_ui.iur_renderer.native_widget_reuse` | `2.3.2` | `3.3.1`, `5.3.1`, `5.3.2` | Direct renderer-stack convergence obligation. |
| `live_ui.iur_renderer.targets_widget_component_boundaries` | `11.2` | `11.2.1`, `11.4` | Phase 11: Canonical IUR maps to widget component boundaries via function components. |
### `transport.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `live_ui.transport.canonical_boundary_events` | `4.1.1` | `4.2.1`, `4.3.1`, `4.5.1` | Direct transport obligation. |
| `live_ui.transport.native_liveview_event_model` | `4.1.2` | `4.2.1`, `4.5.1` | Direct native-event-model obligation. |
| `live_ui.transport.server_authority_preserved` | `4.2.1` | `4.2.2`, `4.5.2`, `1.3.1` | Direct server-authority transport obligation. |
| `live_ui.transport.no_boundary_leakage` | `4.3.1` | `4.1.1`, `4.5.1`, `6.2.2` | Direct contract-hygiene obligation. |
| `live_ui.transport.direct_native_usage_allowed` | `4.1.2` | `4.2.1`, `4.4.1`, `4.5.1` | Direct local-native-interaction obligation. |
### `tooling.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `live_ui.tooling.reference_examples` | `18.1.1` | `18.1.2`, `18.2.1`, `18.4.1` | Phase 18: Maintained reference examples align one-for-one with the repository focused example inventory. |
| `live_ui.tooling.preview_and_inspection` | `18.2.1` | `5.3.1`, `5.3.2`, `6.3.2`, `18.2.2` | Phase 18: Preview and inspection workflows attach native, canonical, and transport review to the aligned focused example ids. |
| `live_ui.tooling.validation_workflow` | `6.3.1` | `4.3.1`, `5.5.1`, `6.5.2`, `18.3.2`, `18.4.2` | Direct tooling obligation. |
| `live_ui.tooling.documentation_surface` | `6.4.1` | `6.4.2`, `6.5.2`, `18.3.1`, `18.4.2` | Direct tooling obligation. |
| `live_ui.tooling.no_package_local_demo_workbench` | `18.2.2` | `18.3.1`, `18.3.2`, `18.4.2` | Phase 18: Retire the package-local demo/workbench and divergent widget catalog in favor of aligned focused examples. |
## Upstream Canonical Input And Authoring Constraints
These specs are referenced by the planning index because they define the
canonical input surface and authored boundary that `live_ui` must consume or
respect. They are not implemented by `live_ui`, but the plan still needs
deliberate task coverage to preserve compatibility.
### `unified-iur/widgets.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.widgets.input_and_navigation` | `2.2.1` | `2.2.2`, `2.3.2`, `4.1.1` | Upstream canonical widget scope consumed by live_ui. |
| `unified_iur.widgets.overlay_and_feedback` | `3.1.1` | `3.2.1`, `3.3.1`, `4.1.1` | Upstream canonical widget scope consumed by live_ui. |
| `unified_iur.widgets.data_and_document_views` | `3.1.1` | `3.3.1`, `3.5.1` | Upstream canonical widget scope consumed by live_ui. |
| `unified_iur.widgets.visualization` | `3.1.1` | `3.3.1`, `5.2.1` | Upstream canonical widget scope consumed by live_ui. |
| `unified_iur.widgets.operational_views` | `3.1.2` | `3.3.1`, `6.1.1` | Upstream canonical widget scope consumed by live_ui. |
| `unified_iur.widgets.widget_semantics_preserved` | `2.3.2` | `3.3.1`, `5.3.2`, `5.5.2` | Upstream parity constraint on renderer behavior. |
### `unified-iur/display_systems.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.display_systems.layout_primitives` | `2.3.1` | `2.3.2`, `3.3.1`, `5.2.1` | Upstream canonical display-system scope consumed by live_ui. |
| `unified_iur.display_systems.layering_primitives` | `3.2.1` | `3.3.1`, `4.1.1`, `5.2.1` | Upstream canonical display-system scope consumed by live_ui. |
| `unified_iur.display_systems.viewport_and_clipping` | `3.2.2` | `3.3.1`, `3.5.1` | Upstream canonical display-system scope consumed by live_ui. |
| `unified_iur.display_systems.canvas_surface` | `3.2.2` | `3.3.1`, `5.2.1` | Upstream canonical display-system scope consumed by live_ui. |
| `unified_iur.display_systems.compose_with_widgets` | `3.3.1` | `2.3.1`, `3.2.1`, `3.2.2` | Upstream composition constraint on runtime behavior. |
### `unified-iur/theming.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.theming.theme_structure` | `5.1.1` | `5.1.2`, `5.2.1`, `5.5.1` | Upstream canonical theming scope consumed by live_ui. |
| `unified_iur.theming.color_model` | `5.1.1` | `5.2.1`, `5.5.1` | Upstream canonical theming scope consumed by live_ui. |
| `unified_iur.theming.text_style_attributes` | `5.1.1` | `5.2.1`, `5.5.1` | Upstream canonical theming scope consumed by live_ui. |
| `unified_iur.theming.semantic_roles` | `5.1.1` | `5.2.1`, `5.4.1` | Upstream canonical theming scope consumed by live_ui. |
| `unified_iur.theming.component_variants` | `5.1.2` | `5.2.1`, `5.2.1`, `5.5.1` | Upstream canonical theming scope consumed by live_ui. |
| `unified_iur.theming.inheritance_and_overrides` | `5.1.2` | `5.2.1`, `5.3.2`, `5.5.1` | Upstream canonical theming scope consumed by live_ui. |
### `unified-iur/interactions.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.interactions.canonical_event_descriptor_representation` | `4.1.1` | `2.3.2`, `4.2.1`, `4.5.1` | Upstream canonical interaction input consumed by live_ui. |
| `unified_iur.interactions.element_binding_attachment` | `2.3.2` | `3.3.1`, `4.2.1` | Upstream canonical interaction input consumed by live_ui. |
| `unified_iur.interactions.renderer_independent_payload_mapping` | `4.1.1` | `4.3.1`, `4.5.1` | Upstream canonical interaction hygiene constraint. |
| `unified_iur.interactions.standard_interaction_families` | `4.1.1` | `2.2.1`, `4.4.1`, `4.5.1` | Upstream canonical interaction scope consumed by live_ui. |
| `unified_iur.interactions.data_binding_representation` | `2.2.1` | `1.2.2`, `4.2.1`, `4.5.2` | Upstream canonical data-binding input consumed by live_ui. |
### `unified-ui/package.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.package.library_identity` | `1.1.2` | `6.4.2` | Upstream ownership guardrail; live_ui must stay separate. |
| `unified_ui.package.dsl_boundary_only` | `1.1.2` | `6.4.2` | Upstream ownership guardrail; live_ui must not absorb DSL responsibilities. |
| `unified_ui.package.canonical_iur_dependency` | `2.3.2` | `3.3.1`, `6.4.1` | Upstream compiler contract consumed by live_ui. |
| `unified_ui.package.standalone_authoring_api` | `1.1.2` | `6.4.2` | Upstream authoring-boundary guardrail. |
| `unified_ui.package.traceable_to_root_specs` | `6.4.1` | `6.4.2` | Upstream governance guardrail reflected in package docs. |
### `unified-ui/signals.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.signals.canonical_descriptor_shape` | `4.1.1` | `2.3.2`, `4.5.1` | Upstream authored-signal input consumed by live_ui. |
| `unified_ui.signals.authoring_event_semantics` | `4.1.1` | `4.3.1`, `6.4.2` | Upstream authored-signal input consumed by live_ui. |
| `unified_ui.signals.standard_interaction_families` | `4.1.1` | `2.2.1`, `4.4.1`, `4.5.1` | Upstream authored-signal scope consumed by live_ui. |
| `unified_ui.signals.validation_and_introspection` | `6.2.1` | `4.3.1`, `6.3.1`, `6.3.2` | Upstream inspection expectations reflected in live_ui maintainer tooling. |
| `unified_ui.signals.no_runtime_local_event_leakage` | `4.3.1` | `1.3.2`, `6.4.2`, `6.5.2` | Upstream authored-signal hygiene guardrail. |
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
