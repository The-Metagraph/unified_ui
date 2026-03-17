defmodule UnifiedExamples.RowTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Row

  test "row example exposes standalone example metadata" do
    metadata = Row.metadata()

    assert metadata.id == :row_example_screen
    assert metadata.root_id == :row_example_screen_root
    assert metadata.widget == :row
    assert metadata.app == :unified_example_row
    assert metadata.directory == "examples/row"
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :click
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
    assert html =~ "Review the row layout story"
    assert html =~ "Meaningful Interaction Story"
  end
end
