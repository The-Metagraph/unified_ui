defmodule DesktopUi.ReferenceTest do
  use ExUnit.Case, async: true

  test "reference and inspection surfaces expose runtime seams and responsibilities" do
    reference = DesktopUi.reference()
    summary = DesktopUi.info()

    assert reference.widgets.validation_state.direct_native_scaffold == :ready
    assert reference.widgets.registration_model.direct_native_only
    assert reference.runtime.validation_state == :runtime_backbone_ready
    assert reference.platform.validation_state == :platform_adapter_ready
    assert reference.layout.validation_state.advanced_display_systems == :ready
    assert reference.layer.validation_state.multiwindow_coordination == :ready

    assert reference.transport.integration_points == [
             :runtime,
             :platform_input_normalization,
             :canonical_signal_translation,
             :transport_diagnostics
           ]

    assert :command in reference.transport.families
    assert :shortcut in reference.transport.input_families
    assert :navigation in reference.transport.boundary_crossing_families
    assert :focus_ring in reference.style.primitives.colors
    assert reference.style.validation_state.direct_native_surface == :ready
    assert reference.theme.default_theme == :desktop_default
    assert :high_contrast in reference.theme.catalog_ids
    assert reference.theme.validation_state.shared_style_model == :ready
    assert reference.platform.integration.mismatches == []
    assert reference.artifacts.workflows.windows.packaging == [:zip_archive, :msi_installer]
    assert reference.artifacts.boundary_policy.transport_semantics_preserved
    assert reference.artifacts.validation_state.packaging_boundaries == :ready

    assert :style_resolution in reference.platform.capability_contract.shared_semantics_outside_platform

    assert reference.transport.modules == [
             DesktopUi.Transport,
             DesktopUi.Transport.Normalize,
             DesktopUi.Transport.Signal,
             DesktopUi.Transport.Diagnostics,
             DesktopUi.Transport.Error
           ]

    assert reference.inspection.package_overview.runtime_foundation == :sdl2
    assert reference.inspection.shared_runtime_contract.direct_native_and_canonical_share_runtime
    assert reference.inspection.transport_contract.no_platform_leakage_guarantee
    assert reference.inspection.layering_contract.multiwindow_runtime
    assert reference.inspection.validation_surface.widgets.focus_metadata == :ready
    assert reference.responsibilities.bounded_platform_variation

    assert summary.package == :desktop_ui
    assert :window in summary.widgets.families
    assert :window in summary.widgets.kinds
    assert :viewport in summary.layout.kinds
    assert :overlay in summary.layer.kinds
    assert :command in summary.transport.families
    assert summary.style.validation_state.component_variants == :ready
    assert summary.theme.default_theme == :desktop_default
    assert summary.platform.integration.mismatches == []
    assert summary.artifacts.workflows.macos.packaging == [:app_bundle, :signed_zip]
    assert summary.artifacts.boundary_policy.packaging_distinct_from_renderer_logic
    assert summary.inspection.validation.runtime == :runtime_backbone_ready
  end
end
