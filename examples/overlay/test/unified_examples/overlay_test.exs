defmodule UnifiedExamples.OverlayTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Overlay

  test "overlay example exposes standalone example metadata" do
    metadata = Overlay.metadata()

    assert metadata.id == :overlay_example_screen
    assert metadata.root_id == :overlay_example_screen_root
    assert metadata.widget == :overlay
    assert metadata.app == :unified_example_overlay
    assert metadata.directory == "examples/overlay"
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :open
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
    assert html =~ "Inspect the overlay layered story"
    assert html =~ "Meaningful Interaction Story"
  end
end
