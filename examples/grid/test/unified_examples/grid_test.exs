defmodule UnifiedExamples.GridTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Grid

  test "grid example exposes standalone example metadata" do
    assert Grid.metadata() == %{
             id: :grid_example_screen,
             root_id: :grid_example_screen_root,
             title: "Grid Widget Example",
             summary: "Focused layout-oriented example using the shared suite shell",
             notes:
               "Grid examples keep the shared shell while foregrounding one multi-cell layout surface.",
             widget: :grid,
             theme_id: :example_suite_default,
             app: :unified_example_grid,
             directory: "examples/grid",
             purpose: :widget_proof
           }
  end

  test "grid example renders the shared shell and foregrounds one primary grid" do
    assert {:ok, runtime_state} = Grid.boot()
    assert {:ok, html} = Grid.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :grid_example_screen_shell

    assert %UnifiedIUR.Element{kind: :grid} =
             Tree.find_by_id(runtime_state.assigns.iur, :grid_example_primary_grid)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"grid\""
    assert html =~ "Grid Widget Example"
    assert html =~ "CPU"
    assert html =~ "132ms"
  end
end
