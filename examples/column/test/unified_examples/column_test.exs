defmodule UnifiedExamples.ColumnTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Column

  test "column example exposes standalone example metadata" do
    assert Column.metadata() == %{
             id: :column_example_screen,
             root_id: :column_example_screen_root,
             title: "Column Widget Example",
             summary: "Focused layout-oriented example using the shared suite shell",
             notes:
               "Column examples keep the shared shell while foregrounding one vertical layout flow.",
             widget: :column,
             theme_id: :example_suite_default,
             app: :unified_example_column,
             directory: "examples/column",
             purpose: :widget_proof
           }
  end

  test "column example renders the shared shell and foregrounds one primary column" do
    assert {:ok, runtime_state} = Column.boot()
    assert {:ok, html} = Column.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :column_example_screen_shell

    assert %UnifiedIUR.Element{kind: :column} =
             Tree.find_by_id(runtime_state.assigns.iur, :column_example_primary_column)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"column\""
    assert html =~ "Column Widget Example"
    assert html =~ "On-call checklist"
    assert html =~ "Acknowledge"
  end
end
