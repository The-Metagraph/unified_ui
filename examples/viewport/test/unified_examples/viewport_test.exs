defmodule UnifiedExamples.ViewportTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Viewport

  test "viewport example exposes standalone example metadata" do
    assert Viewport.metadata() == %{
             id: :viewport_example_screen,
             root_id: :viewport_example_screen_root,
             title: "Viewport Widget Example",
             summary: "Focused display-system example using the shared suite shell",
             notes:
               "Viewport examples foreground one canonical clipped region inside the shared shell.",
             widget: :viewport,
             theme_id: :example_suite_default,
             app: :unified_example_viewport,
             directory: "examples/viewport",
             purpose: :widget_proof
           }
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
  end
end
