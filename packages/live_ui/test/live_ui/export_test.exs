defmodule LiveUi.ExportTest do
  use ExUnit.Case, async: true

  test "export can render stable metadata and html for maintained examples" do
    assert {:ok, metadata} = LiveUi.Export.example(:native_styled_profile, :metadata)
    assert metadata =~ "native_styled_profile"
    assert metadata =~ "preview_id"

    assert {:ok, html} = LiveUi.Export.example(:canonical_styled_operations, :html)
    assert html =~ "data-live-ui-widget=\"overlay-surface\""
    assert html =~ "data-live-ui-widget=\"cluster-dashboard\""
  end

  test "export can print comparison and diagnostics output for paired examples" do
    assert {:ok, comparison} = LiveUi.Export.example(:native_styled_operations, :comparison)
    assert comparison =~ "native_styled_operations"
    assert comparison =~ "canonical_styled_operations"
    assert comparison =~ "widgets_aligned?"

    assert {:ok, diagnostics} = LiveUi.Export.example(:native_styled_profile, :diagnostics)
    assert diagnostics =~ "diagnostics"
    assert diagnostics =~ "canonical_styled_profile"
  end
end
