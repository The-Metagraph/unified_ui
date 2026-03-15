defmodule UnifiedExamples.RowTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Row

  test "row example exposes standalone example metadata" do
    assert Row.metadata() == %{
             id: :row_example_screen,
             root_id: :row_example_screen_root,
             title: "Row Widget Example",
             summary: "Focused layout-oriented example using the shared suite shell",
             notes:
               "Row examples keep the shared shell while foregrounding one horizontal layout flow.",
             widget: :row,
             theme_id: :example_suite_default,
             app: :unified_example_row,
             directory: "examples/row",
             purpose: :widget_proof
           }
  end

  test "row example renders the shared shell and foregrounds one primary row" do
    assert {:ok, runtime_state} = Row.boot()
    assert {:ok, html} = Row.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :row_example_screen_shell

    assert %UnifiedIUR.Element{kind: :row} =
             Tree.find_by_id(runtime_state.assigns.iur, :row_example_primary_row)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"row\""
    assert html =~ "Row Widget Example"
    assert html =~ "Release train"
    assert html =~ "Queue active"
    assert html =~ "Review"
  end
end
