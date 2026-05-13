# UnifiedUi Spec Traceability Matrix
Generated from the authoritative machine-readable source: [spec-traceability.json](./spec-traceability.json)
This document maps the `unified_ui` implementation plan to the specs referenced by
the planning index. It makes explicit which requirements are delivered directly
by the `unified_ui` plan, which ones are inherited from root ecosystem contracts,
and which upstream package specs are treated as input constraints rather than
`unified_ui`-owned deliverables.
## How To Read This Matrix
- `Primary plan coverage` points at the first task that is expected to satisfy
  the requirement intentionally.
- `Supporting coverage` points at later tasks that broaden, validate, document,
  or harden the same contract.
- `Ownership note` distinguishes direct `unified_ui` work from inherited or
  upstream constraints.
- Requirement statements remain authoritative in the source spec files; this
  matrix only traces those requirements into plan work.
## Inherited Root Ecosystem Requirements
### `architecture.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.architecture.dsl_authoring_boundary` | `1.2.1` | - | Inherited authored-boundary requirement for UnifiedUi. |
| `ecosystem.architecture.iur_exchange_boundary` | `5.1.1` | - | Inherited canonical-exchange boundary requirement. |
| `ecosystem.architecture.shared_transport_contract` | `4.3.1` | - | Inherited shared signal-contract requirement. |
### `dsl_iur_symbiosis.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.dsl_iur_symbiosis.dsl_entities_have_iur_representation` | `5.1.2` | - | Inherited DSL-to-IUR symmetry requirement. |
| `ecosystem.dsl_iur_symbiosis.canonical_iur_constructs_representable_in_dsl` | `5.4.1` | - | Inherited parity requirement between canonical IUR and DSL coverage. |
| `ecosystem.dsl_iur_symbiosis.iur_covers_widget_layout_layer_theme` | `5.4.1` | - | Inherited parity requirement for widgets, layout, layering, and themes. |
| `ecosystem.dsl_iur_symbiosis.layering_and_theming_stay_in_dsl` | `3.3.2` | - | Inherited authored-surface requirement for layers and themes. |
| `ecosystem.dsl_iur_symbiosis.dsl_compiles_to_iur` | `5.1.1` | - | Inherited compilation-to-IUR requirement. |
| `ecosystem.dsl_iur_symbiosis.bilateral_change_rule` | `5.4.1` | - | Inherited bilateral parity governance requirement. |
| `ecosystem.dsl_iur_symbiosis.consumer_originated_widget_promotion` | `5.4.1` | `6.3.1`, `6.4.1` | Inherited bilateral-promotion rule for consumer-originated widgets authored in UnifiedUi. |
### `signal_transport.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.signal_transport.jido_signal_canonical` | `4.3.1` | - | Inherited canonical signal-contract requirement. |
| `ecosystem.signal_transport.dsl_event_bindings` | `4.3.2` | - | Inherited authored binding-to-signal requirement. |
### Referenced Root Requirements Outside `unified_ui` Ownership
These referenced root requirements are intentionally not mapped to `unified_ui`
tasks because they govern other runtime packages:
- `ecosystem.architecture.renderer_packages_consume_iur`
- `ecosystem.architecture.runtime_libraries_native_surface`
- `ecosystem.architecture.runtime_libraries_iur_renderer`
- `ecosystem.platform_runtimes.widget_libraries_independent`
- `ecosystem.platform_runtimes.native_surface_covers_iur`
- `ecosystem.platform_runtimes.native_surface_usable_without_iur`
- `ecosystem.platform_runtimes.iur_interpretation`
- `ecosystem.platform_runtimes.elm_ui_runtime_split`
- `ecosystem.platform_runtimes.live_ui_runtime`
- `ecosystem.platform_runtimes.desktop_ui_targets`
- `ecosystem.platform_runtimes.desktop_ui_native_runtime`
- `ecosystem.signal_transport.elm_ui_bridge`
- `ecosystem.signal_transport.live_bridge`
- `ecosystem.signal_transport.desktop_translation`
- `ecosystem.signal_transport.native_signal_models_allowed`
- `ecosystem.signal_transport.local_state_not_contract`
## Direct `unified_ui` Spec Requirements
### `unified-ui/package.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.package.library_identity` | `1.1.1` | - | Direct package identity requirement. |
| `unified_ui.package.canonical_iur_dependency` | `1.1.1` | - | Direct package dependency requirement. |
| `unified_ui.package.dsl_boundary_only` | `1.1.2` | - | Direct authored-boundary requirement. |
| `unified_ui.package.standalone_authoring_api` | `1.2.1` | - | Direct author-facing API requirement. |
| `unified_ui.package.traceable_to_root_specs` | `6.4.1` | - | Direct spec-traceability requirement. |
### `unified-ui/structure.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.structure.mix_package_layout` | `1.1.1` | - | Direct package layout requirement. |
| `unified_ui.structure.dsl_modules` | `1.1.2` | - | Direct DSL module-boundary requirement. |
| `unified_ui.structure.compiler_modules` | `5.1.1` | - | Direct compiler module-boundary requirement. |
| `unified_ui.structure.signal_modules` | `4.3.1` | - | Direct signal module-boundary requirement. |
| `unified_ui.structure.introspection_and_reference` | `1.4.1` | - | Direct introspection and reference-module requirement. |
| `unified_ui.structure.no_required_long_lived_runtime` | `1.1.2` | - | Direct pure-library runtime-boundary requirement. |
### `unified-ui/dsl.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.dsl.authoring_extensibility` | `1.2.2` | - | Direct DSL extensibility requirement. |
| `unified_ui.dsl.compile_time_validation` | `1.3.2` | - | Direct compile-time validation requirement. |
| `unified_ui.dsl.interaction_binding` | `4.3.2` | - | Direct interaction and binding DSL requirement. |
| `unified_ui.dsl.spark_style_authoring_surface` | `1.2.1` | - | Direct Spark-style authoring requirement. |
| `unified_ui.dsl.styling_and_theming` | `4.1.1` | - | Direct style and theme DSL requirement. |
| `unified_ui.dsl.widgets_layouts_layers` | `1.2.2` | - | Direct widget, layout, and layer authoring-surface requirement. |
| `unified_ui.dsl.consumer_originated_surface_promotion` | `1.2.2` | `1.3.2`, `6.4.1` | Direct DSL support for promoting portable consumer-originated widget concepts. |
| `unified_ui.dsl.repeated_collection_templates` | `1.2.2` | `1.3.2`, `5.2.2`, `6.3.1` | Direct DSL support for repeated collection templates and row-scope descriptors. |
### `unified-ui/widgets.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.widgets.canvas_surface` | `3.3.2` | - | Direct canvas widget authoring requirement. |
| `unified_ui.widgets.feedback_navigation_data_surface` | `3.1.1` | - | Direct advanced widget family requirement. |
| `unified_ui.widgets.foundational_visual_surface` | `2.1.1` | - | Direct foundational widget requirement. |
| `unified_ui.widgets.input_surface` | `2.2.1` | - | Direct input and form widget requirement. |
| `unified_ui.widgets.iur_surface_parity` | `5.4.1` | - | Direct parity requirement against canonical UnifiedIUR. |
| `unified_ui.widgets.layout_and_layer_surface` | `2.3.1` | - | Direct layout and layer authoring requirement. |
| `unified_ui.widgets.style_attribute_surface` | `4.2.1` | - | Direct canonical style attribute requirement. |
| `unified_ui.widgets.portable_semantic_micro_widgets` | `3.1.1` | `5.4.1`, `6.1.1`, `6.3.1` | Direct authored widget coverage for promoted semantic and micro-interaction widgets. |
| `unified_ui.widgets.portable_workflow_document_widgets` | `3.1.2` | `5.4.1`, `6.1.1`, `6.3.1` | Direct authored widget coverage for promoted workflow, document, and composer widgets. |
| `unified_ui.widgets.repeated_collection_composition` | `3.4.2` | `5.2.2`, `5.4.1`, `6.3.1` | Direct authored coverage for repeated collection composition and row-scope preservation. |
### `unified-ui/display_systems.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.display_systems.canvas_surface` | `3.3.2` | - | Direct display-system canvas requirement. |
| `unified_ui.display_systems.compose_with_widgets` | `3.4.2` | - | Direct display-system composition requirement. |
| `unified_ui.display_systems.layering_primitives` | `3.3.2` | - | Direct layering construct requirement. |
| `unified_ui.display_systems.layout_primitives` | `2.3.1` | - | Direct layout construct requirement. |
| `unified_ui.display_systems.viewport_and_clipping` | `3.3.1` | - | Direct viewport and clipping requirement. |
### `unified-ui/theming.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.theming.color_model` | `4.1.1` | - | Direct theming color-model requirement. |
| `unified_ui.theming.component_variants` | `4.1.2` | - | Direct theming component-variant requirement. |
| `unified_ui.theming.inheritance_and_overrides` | `4.1.2` | - | Direct theming inheritance requirement. |
| `unified_ui.theming.semantic_roles` | `4.1.1` | - | Direct theming semantic-role requirement. |
| `unified_ui.theming.text_style_attributes` | `4.2.1` | - | Direct theming text-style requirement. |
| `unified_ui.theming.theme_structure` | `4.1.1` | - | Direct theme structure requirement. |
### `unified-ui/signals.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.signals.authoring_event_semantics` | `4.3.1` | - | Direct authored signal-semantics requirement. |
| `unified_ui.signals.canonical_descriptor_shape` | `4.3.2` | - | Direct canonical descriptor-shape requirement. |
| `unified_ui.signals.no_runtime_local_event_leakage` | `4.4.2` | - | Direct runtime-leakage rejection requirement. |
| `unified_ui.signals.standard_interaction_families` | `4.3.1` | - | Direct standard interaction-family requirement. |
| `unified_ui.signals.validation_and_introspection` | `4.4.2` | - | Direct signal validation and introspection requirement. |
### `unified-ui/compiler.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.compiler.canonical_iur_output` | `5.1.2` | - | Direct canonical compilation-output requirement. |
| `unified_ui.compiler.deterministic_results` | `5.2.1` | - | Direct deterministic compilation requirement. |
| `unified_ui.compiler.introspection_surface` | `5.3.1` | - | Direct compiled-output inspection requirement. |
| `unified_ui.compiler.no_renderer_output_modes` | `5.4.2` | - | Direct renderer-independence requirement for compilation output. |
| `unified_ui.compiler.runtime_independent_bindings` | `5.2.2` | - | Direct runtime-independent binding compilation requirement. |
| `unified_ui.compiler.style_theme_layer_resolution` | `5.2.1` | - | Direct style, theme, and layer resolution requirement. |
### `unified-ui/tooling.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_ui.tooling.authoring_validation_workflow` | `6.3.1` | - | Direct validation-workflow requirement. |
| `unified_ui.tooling.compiler_inspection` | `6.2.1` | - | Direct compiler inspection tooling requirement. |
| `unified_ui.tooling.documentation_surface` | `6.4.1` | - | Direct documentation-surface requirement. |
| `unified_ui.tooling.reference_examples` | `6.1.1` | - | Direct maintained example requirement. |
## Upstream Canonical Input And Authoring Constraints
These specs are referenced by the planning index because they define the
canonical input surface and authored boundary that `unified_ui` must consume or
respect. They are not implemented by `unified_ui`, but the plan still needs
deliberate task coverage to preserve compatibility.
### `unified-iur/package.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.package.exchange_boundary` | `5.1.1` | - | Upstream canonical exchange-boundary constraint consumed by UnifiedUi. |
| `unified_iur.package.renderer_independent_surface` | `5.1.2` | - | Upstream renderer-independent surface constraint consumed by UnifiedUi. |
### `unified-iur/core.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.core.canonical_element_model` | `5.1.2` | - | Upstream canonical element-model constraint consumed by UnifiedUi. |
| `unified_iur.core.child_relationship_model` | `5.1.2` | - | Upstream child-relationship constraint consumed by UnifiedUi. |
| `unified_iur.core.identity_and_metadata` | `5.1.2` | - | Upstream identity-and-metadata constraint consumed by UnifiedUi. |
| `unified_iur.core.pure_immutable_values` | `5.2.1` | - | Upstream immutable-value constraint consumed by UnifiedUi. |
### `unified-iur/constructs.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.constructs.canonical_surface_for_runtime_parity` | `5.4.1` | - | Upstream parity-surface constraint consumed by UnifiedUi. |
| `unified_iur.constructs.foundational_widgets` | `2.1.1` | - | Upstream foundational widget constraint consumed by UnifiedUi. |
| `unified_iur.constructs.input_and_form_widgets` | `2.2.1` | - | Upstream input and form constraint consumed by UnifiedUi. |
| `unified_iur.constructs.layout_and_layering` | `2.3.1` | - | Upstream layout and layering constraint consumed by UnifiedUi. |
| `unified_iur.constructs.navigation_feedback_and_data` | `3.1.1` | - | Upstream navigation, feedback, and data constraint consumed by UnifiedUi. |
| `unified_iur.constructs.styling_attributes` | `4.2.1` | - | Upstream styling-attribute constraint consumed by UnifiedUi. |
| `unified_iur.constructs.theme_and_token_representation` | `4.1.1` | - | Upstream theme and token constraint consumed by UnifiedUi. |
| `unified_iur.constructs.repeated_collection_composition` | `5.4.1` | `5.2.2`, `6.3.1` | Upstream canonical repeated-collection construct consumed by UnifiedUi. |
### `unified-iur/display_systems.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.display_systems.canvas_surface` | `3.3.2` | - | Upstream canvas-display constraint consumed by UnifiedUi. |
| `unified_iur.display_systems.compose_with_widgets` | `3.4.2` | - | Upstream display composition constraint consumed by UnifiedUi. |
| `unified_iur.display_systems.layering_primitives` | `3.3.2` | - | Upstream layering constraint consumed by UnifiedUi. |
| `unified_iur.display_systems.layout_primitives` | `2.3.1` | - | Upstream layout constraint consumed by UnifiedUi. |
| `unified_iur.display_systems.viewport_and_clipping` | `3.3.1` | - | Upstream viewport constraint consumed by UnifiedUi. |
### `unified-iur/interactions.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.interactions.canonical_event_descriptor_representation` | `4.3.2` | - | Upstream canonical interaction-descriptor constraint consumed by UnifiedUi. |
| `unified_iur.interactions.data_binding_representation` | `4.3.2` | - | Upstream data-binding descriptor constraint consumed by UnifiedUi. |
| `unified_iur.interactions.element_binding_attachment` | `4.3.2` | - | Upstream binding-attachment constraint consumed by UnifiedUi. |
| `unified_iur.interactions.renderer_independent_payload_mapping` | `4.3.2` | - | Upstream payload-mapping constraint consumed by UnifiedUi. |
| `unified_iur.interactions.standard_interaction_families` | `4.3.1` | - | Upstream interaction-family constraint consumed by UnifiedUi. |
| `unified_iur.interactions.row_scope_binding_representation` | `5.2.2` | `5.4.1`, `6.3.1` | Upstream row-scope binding representation consumed by UnifiedUi authoring and lowering. |
### `unified-iur/interoperability.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.interoperability.deterministic_shape` | `5.2.1` | - | Upstream deterministic-shape constraint consumed by UnifiedUi. |
| `unified_iur.interoperability.no_runtime_local_escape_hatches` | `4.4.2` | - | Upstream renderer-leakage constraint consumed by UnifiedUi. |
| `unified_iur.interoperability.portable_data_model` | `5.1.2` | - | Upstream portable-data constraint consumed by UnifiedUi. |
| `unified_iur.interoperability.runtime_library_consumption` | `5.4.1` | - | Upstream runtime-consumption constraint consumed by UnifiedUi. |
### `unified-iur/theming.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.theming.color_model` | `4.1.1` | - | Upstream theming color-model constraint consumed by UnifiedUi. |
| `unified_iur.theming.component_variants` | `4.1.2` | - | Upstream theming variant constraint consumed by UnifiedUi. |
| `unified_iur.theming.inheritance_and_overrides` | `4.1.2` | - | Upstream theming inheritance constraint consumed by UnifiedUi. |
| `unified_iur.theming.semantic_roles` | `4.1.1` | - | Upstream semantic-role constraint consumed by UnifiedUi. |
| `unified_iur.theming.text_style_attributes` | `4.2.1` | - | Upstream text-style constraint consumed by UnifiedUi. |
| `unified_iur.theming.theme_structure` | `4.1.1` | - | Upstream theme-structure constraint consumed by UnifiedUi. |
### `unified-iur/tooling.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.tooling.introspection_helpers` | `6.2.1` | - | Upstream inspection-helper constraint consumed by UnifiedUi. |
| `unified_iur.tooling.reference_examples` | `6.1.1` | - | Upstream reference-example constraint consumed by UnifiedUi. |
| `unified_iur.tooling.validation_workflow` | `6.3.1` | - | Upstream validation-workflow constraint consumed by UnifiedUi. |
### `unified-iur/widgets.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.widgets.portable_semantic_micro_widgets` | `5.4.1` | `6.3.1` | Upstream canonical IUR representation required by promoted semantic widget authoring. |
| `unified_iur.widgets.workflow_document_widgets` | `5.4.1` | `6.3.1` | Upstream canonical IUR representation required by promoted workflow widget authoring. |
| `unified_iur.widgets.no_integration_package_widget_escape_hatches` | `5.4.1` | `6.3.1` | Upstream canonical constraint preventing AshUi-only widget escape hatches. |
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
