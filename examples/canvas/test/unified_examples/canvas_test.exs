defmodule UnifiedExamples.CanvasTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Canvas

  test "canvas example exposes standalone example metadata" do
    assert Canvas.metadata() == %{
             id: :canvas_example_screen,
             root_id: :canvas_example_screen_root,
             title: "Canvas Widget Example",
             summary: "Focused display-system example using the shared suite shell",
             notes:
               "Canvas examples foreground one canonical drawing surface inside the shared shell.",
             widget: :canvas,
             theme_id: :example_suite_default,
             app: :unified_example_canvas,
             directory: "examples/canvas",
             purpose: :widget_proof
           }
  end

  test "canvas example renders the shared shell and foregrounds one primary canvas" do
    assert {:ok, runtime_state} = Canvas.boot()
    assert {:ok, html} = Canvas.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :canvas_example_screen_shell

    assert %UnifiedIUR.Element{kind: :canvas} =
             Tree.find_by_id(runtime_state.assigns.iur, :canvas_example_primary_canvas)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"canvas\""
    assert html =~ "data-live-ui-canvas-op=\"cell\""
    assert html =~ "Alert"
    assert html =~ "Canvas Widget Example"
  end
end
