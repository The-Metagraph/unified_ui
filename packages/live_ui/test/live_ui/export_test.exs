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
    assert comparison =~ "browser_style_aligned?"
    assert comparison =~ "browser_style"

    assert {:ok, diagnostics} = LiveUi.Export.example(:native_styled_profile, :diagnostics)
    assert diagnostics =~ "diagnostics"
    assert diagnostics =~ "canonical_styled_profile"
    assert diagnostics =~ "native_browser_style"
  end

  test "export can print style-focused output and browser-style artifacts" do
    assert {:ok, style} = LiveUi.Export.example(:native_styled_profile, :style)
    assert style =~ "browser_style_nodes"
    assert style =~ "realized_entry_ids"

    assert {:ok, artifact} = LiveUi.Export.example(:native_styled_profile, :artifact)
    assert artifact =~ "browser_style_nodes"
    assert artifact =~ "html"
    assert artifact =~ "canonical"
  end
end
