defmodule UnifiedExamples.OverlayTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Overlay

  test "overlay example exposes standalone example metadata" do
    assert Overlay.metadata() == %{
             id: :overlay_example_screen,
             root_id: :overlay_example_screen_root,
             title: "Overlay Widget Example",
             summary: "Focused overlay example using the shared suite shell",
             notes:
               "Overlay examples foreground one canonical layered surface inside the shared shell.",
             widget: :overlay,
             theme_id: :example_suite_default,
             app: :unified_example_overlay,
             directory: "examples/overlay",
             purpose: :widget_proof
           }
  end

  test "overlay example renders the shared shell and foregrounds one primary overlay surface" do
    assert {:ok, runtime_state} = Overlay.boot()
    assert {:ok, html} = Overlay.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :overlay_example_screen_shell

    assert %UnifiedIUR.Element{kind: :overlay} =
             Tree.find_by_id(runtime_state.assigns.iur, :overlay_example_primary_overlay)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"overlay-surface\""
    assert html =~ "Overlay Widget Example"
    assert html =~ "Coordinator workspace"
    assert html =~ "Runbook synced"
  end
end
