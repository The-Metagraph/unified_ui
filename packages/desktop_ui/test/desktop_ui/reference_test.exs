defmodule DesktopUi.ReferenceTest do
  use ExUnit.Case, async: true

  test "reference and inspection surfaces expose runtime seams and responsibilities" do
    reference = DesktopUi.reference()
    summary = DesktopUi.info()

    assert reference.widgets.validation_state.direct_native_scaffold == :ready
    assert reference.widgets.registration_model.direct_native_only
    assert reference.runtime.validation_state == :runtime_backbone_ready
    assert reference.platform.validation_state == :platform_adapter_ready

    assert reference.transport.integration_points == [
             :runtime,
             :platform_input_normalization,
             :canonical_signal_translation
           ]

    assert reference.inspection.package_overview.runtime_foundation == :sdl2
    assert reference.inspection.shared_runtime_contract.direct_native_and_canonical_share_runtime
    assert reference.inspection.validation_surface.widgets.focus_metadata == :ready
    assert reference.responsibilities.bounded_platform_variation

    assert summary.package == :desktop_ui
    assert :window in summary.widgets.families
    assert :window in summary.widgets.kinds
    assert summary.inspection.validation.runtime == :runtime_backbone_ready
  end
end
