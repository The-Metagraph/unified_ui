# UnifiedIur Spec Traceability Matrix
Generated from the authoritative machine-readable source: [spec-traceability.json](./spec-traceability.json)
This document maps the `unified_iur` implementation plan to the specs referenced by
the planning index. It makes explicit which requirements are delivered directly
by the `unified_iur` plan, which ones are inherited from root ecosystem contracts,
and which upstream package specs are treated as input constraints rather than
`unified_iur`-owned deliverables.
## How To Read This Matrix
- `Primary plan coverage` points at the first task that is expected to satisfy
  the requirement intentionally.
- `Supporting coverage` points at later tasks that broaden, validate, document,
  or harden the same contract.
- `Ownership note` distinguishes direct `unified_iur` work from inherited or
  upstream constraints.
- Requirement statements remain authoritative in the source spec files; this
  matrix only traces those requirements into plan work.
## Inherited Root Ecosystem Requirements
### `architecture.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.architecture.iur_exchange_boundary` | `5.2.1` | `6.3.1` | Inherited exchange-boundary requirement for UnifiedIUR. |
| `ecosystem.architecture.shared_transport_contract` | `4.3.1` | `4.5.2` | Inherited transport-contract guardrail for canonical interaction descriptors. |
### `dsl_iur_symbiosis.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `ecosystem.dsl_iur_symbiosis.dsl_entities_have_iur_representation` | `5.4.2` | - | Inherited parity requirement between authored DSL entities and canonical IUR. |
| `ecosystem.dsl_iur_symbiosis.canonical_iur_constructs_representable_in_dsl` | `5.4.2` | - | Inherited bilateral authoring parity requirement. |
| `ecosystem.dsl_iur_symbiosis.iur_covers_widget_layout_layer_theme` | `5.4.2` | - | Inherited canonical-coverage requirement for widgets, layout, layering, styling, and themes. |
| `ecosystem.dsl_iur_symbiosis.layering_and_theming_stay_in_dsl` | `5.4.2` | - | Inherited symbiosis guardrail for layering and theming. |
| `ecosystem.dsl_iur_symbiosis.dsl_compiles_to_iur` | `5.1.1` | - | Inherited compilation-target requirement for canonical IUR. |
| `ecosystem.dsl_iur_symbiosis.bilateral_change_rule` | `5.4.2` | - | Inherited bilateral change-management requirement. |
### Referenced Root Requirements Outside `unified_iur` Ownership
These referenced root requirements are intentionally not mapped to `unified_iur`
tasks because they govern other runtime packages:
- `ecosystem.architecture.dsl_authoring_boundary`
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
- `ecosystem.signal_transport.jido_signal_canonical`
- `ecosystem.signal_transport.dsl_event_bindings`
- `ecosystem.signal_transport.elm_ui_bridge`
- `ecosystem.signal_transport.live_bridge`
- `ecosystem.signal_transport.desktop_translation`
- `ecosystem.signal_transport.native_signal_models_allowed`
- `ecosystem.signal_transport.local_state_not_contract`
## Direct `unified_iur` Spec Requirements
### `unified-iur/package.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.package.library_identity` | `1.1.1` | `1.5.2` | Direct package identity requirement. |
| `unified_iur.package.exchange_boundary` | `5.2.1` | `5.5.1` | Direct canonical exchange-boundary requirement. |
| `unified_iur.package.renderer_independent_surface` | `1.2.1` | `5.2.2` | Direct renderer-independent surface requirement. |
| `unified_iur.package.direct_runtime_consumption` | `5.2.1` | `6.3.1` | Direct runtime-library consumption requirement. |
| `unified_iur.package.traceable_to_root_specs` | `6.4.1` | `6.4.2` | Direct traceability-to-root-specs requirement. |
### `unified-iur/structure.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.structure.mix_library_layout` | `1.1.1` | - | Direct Mix package layout requirement. |
| `unified_iur.structure.core_and_construct_module_split` | `1.1.2` | - | Direct module-boundary requirement for core and construct areas. |
| `unified_iur.structure.no_long_lived_runtime` | `1.1.2` | `1.5.2` | Direct pure-library runtime-boundary requirement. |
| `unified_iur.structure.normalization_and_conversion_modules` | `5.1.1` | - | Direct normalization and conversion module-boundary requirement. |
| `unified_iur.structure.reference_and_introspection_modules` | `1.4.1` | `6.2.1` | Direct reference and introspection module requirement. |
### `unified-iur/core.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.core.canonical_element_model` | `1.2.1` | - | Direct canonical element-model requirement. |
| `unified_iur.core.identity_and_metadata` | `1.2.1` | `1.2.2` | Direct identity and metadata requirement. |
| `unified_iur.core.child_relationship_model` | `1.3.1` | - | Direct child-relationship requirement. |
| `unified_iur.core.pure_immutable_values` | `1.4.2` | `1.5.1` | Direct immutable-value requirement. |
| `unified_iur.core.extensible_without_breaking_shape` | `5.4.1` | `5.5.2` | Direct extensibility-without-breaking-shape requirement. |
### `unified-iur/constructs.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.constructs.foundational_widgets` | `2.1.1` | - | Direct foundational widget construct requirement. |
| `unified_iur.constructs.input_and_form_widgets` | `2.2.1` | `2.2.2` | Direct input and form construct requirement. |
| `unified_iur.constructs.layout_and_layering` | `2.3.1` | `3.1.1` | Direct layout and layering construct requirement. |
| `unified_iur.constructs.navigation_feedback_and_data` | `2.4.1` | `2.4.2` | Direct navigation, feedback, and data construct requirement. |
| `unified_iur.constructs.styling_attributes` | `4.1.1` | `4.4.1` | Direct styling-attribute construct requirement. |
| `unified_iur.constructs.theme_and_token_representation` | `4.2.1` | `4.2.2` | Direct theme and token construct requirement. |
| `unified_iur.constructs.canonical_surface_for_runtime_parity` | `5.2.1` | `5.4.2` | Direct canonical-surface parity requirement. |
### `unified-iur/widgets.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.widgets.input_and_navigation` | `2.2.1` | `2.4.1` | Direct input and navigation widget requirement. |
| `unified_iur.widgets.data_and_document_views` | `2.4.1` | `3.4.2` | Direct data and document widget requirement. |
| `unified_iur.widgets.overlay_and_feedback` | `3.1.1` | `3.1.2` | Direct overlay and feedback widget requirement. |
| `unified_iur.widgets.visualization` | `3.3.2` | - | Direct visualization widget requirement. |
| `unified_iur.widgets.operational_views` | `3.4.1` | `3.4.2` | Direct operational widget requirement. |
| `unified_iur.widgets.widget_semantics_preserved` | `2.1.2` | `5.3.2` | Direct widget-semantics preservation requirement. |
### `unified-iur/display_systems.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.display_systems.layout_primitives` | `2.3.1` | - | Direct layout-primitive requirement. |
| `unified_iur.display_systems.layering_primitives` | `3.1.1` | - | Direct layering-primitive requirement. |
| `unified_iur.display_systems.viewport_and_clipping` | `3.2.1` | - | Direct viewport and clipping requirement. |
| `unified_iur.display_systems.canvas_surface` | `3.3.1` | - | Direct canvas-surface requirement. |
| `unified_iur.display_systems.compose_with_widgets` | `3.5.1` | `2.3.1`, `3.3.1` | Direct display-system composition requirement. |
### `unified-iur/theming.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.theming.color_model` | `4.1.1` | - | Direct theming color-model requirement. |
| `unified_iur.theming.text_style_attributes` | `4.1.1` | - | Direct theming text-style attribute requirement. |
| `unified_iur.theming.theme_structure` | `4.2.1` | - | Direct theme-structure requirement. |
| `unified_iur.theming.semantic_roles` | `4.2.1` | - | Direct semantic-role requirement. |
| `unified_iur.theming.component_variants` | `4.2.1` | - | Direct component-variant requirement. |
| `unified_iur.theming.inheritance_and_overrides` | `4.2.2` | `4.4.1` | Direct theme inheritance and override requirement. |
### `unified-iur/interactions.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.interactions.canonical_event_descriptor_representation` | `4.3.1` | - | Direct canonical interaction-descriptor requirement. |
| `unified_iur.interactions.renderer_independent_payload_mapping` | `4.3.1` | - | Direct renderer-independent payload-mapping requirement. |
| `unified_iur.interactions.standard_interaction_families` | `4.3.1` | - | Direct standard interaction-family requirement. |
| `unified_iur.interactions.data_binding_representation` | `4.3.2` | - | Direct data-binding representation requirement. |
| `unified_iur.interactions.element_binding_attachment` | `4.4.2` | `4.3.2` | Direct binding-attachment requirement. |
### `unified-iur/interoperability.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.interoperability.runtime_library_consumption` | `5.2.1` | `5.5.1` | Direct runtime-library consumption requirement. |
| `unified_iur.interoperability.portable_data_model` | `5.2.1` | `5.3.1` | Direct portable-data-model requirement. |
| `unified_iur.interoperability.no_runtime_local_escape_hatches` | `5.2.2` | `5.5.1` | Direct runtime-local escape-hatch rejection requirement. |
| `unified_iur.interoperability.deterministic_shape` | `5.3.1` | `5.5.2` | Direct deterministic-shape requirement. |
| `unified_iur.interoperability.extension_strategy` | `5.4.1` | `5.4.2` | Direct extension-strategy requirement. |
### `unified-iur/tooling.spec.md`
| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |
| --- | --- | --- | --- |
| `unified_iur.tooling.reference_examples` | `6.1.1` | `6.1.2` | Direct reference-fixture requirement. |
| `unified_iur.tooling.introspection_helpers` | `6.2.1` | - | Direct inspection and export tooling requirement. |
| `unified_iur.tooling.validation_workflow` | `6.3.1` | `6.3.2` | Direct validation-workflow requirement. |
| `unified_iur.tooling.documentation_surface` | `6.4.1` | `6.4.2` | Direct documentation-surface requirement. |
## Upstream Canonical Input And Authoring Constraints
These specs are referenced by the planning index because they define the
canonical input surface and authored boundary that `unified_iur` must consume or
respect. They are not implemented by `unified_iur`, but the plan still needs
deliberate task coverage to preserve compatibility.
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
