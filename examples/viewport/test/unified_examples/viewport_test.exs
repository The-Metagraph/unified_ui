defmodule UnifiedExamples.ViewportTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Viewport

  test "viewport example exposes standalone example metadata" do
    metadata = Viewport.metadata()

    assert metadata.id == :viewport_example_screen
    assert metadata.root_id == :viewport_example_screen_root
    assert metadata.widget == :viewport
    assert metadata.app == :unified_example_viewport
    assert metadata.directory == "examples/viewport"
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :focus
  end

  test "viewport example renders the shared shell and foregrounds one primary viewport" do
    assert {:ok, runtime_state} = Viewport.boot()
    assert {:ok, html} = Viewport.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :viewport_example_screen_shell

    assert %UnifiedIUR.Element{kind: :viewport} =
             Tree.find_by_id(runtime_state.assigns.iur, :viewport_example_primary_viewport)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"viewport\""
    assert html =~ "data-live-ui-viewport-slot=\"content\""
    assert html =~ "Viewport Widget Example"
    assert html =~ "Incident timeline"
    assert html =~ "Inspect the viewport display story"
    assert html =~ "Meaningful Interaction Story"
  end
end
