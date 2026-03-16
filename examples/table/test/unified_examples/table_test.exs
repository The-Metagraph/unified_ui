defmodule UnifiedExamples.TableTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Table

  test "table example exposes standalone example metadata" do
    metadata = Table.metadata()

    assert metadata.id == :table_example_screen
    assert metadata.root_id == :table_example_screen_root
    assert metadata.widget == :table
    assert metadata.app == :unified_example_table
    assert metadata.directory == "examples/table"
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :selection
  end

  test "table example renders the shared shell and foregrounds one primary table" do
    assert {:ok, runtime_state} = Table.boot()
    assert {:ok, html} = Table.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :table_example_screen_shell

    assert %UnifiedIUR.Element{kind: :table} =
             Tree.find_by_id(runtime_state.assigns.iur, :table_example_primary_table)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"table\""
    assert html =~ "Table Widget Example"
    assert html =~ "API"
    assert html =~ "Healthy"
    assert html =~ "Platform"
    assert html =~ "Inspect the table data story"
    assert html =~ "Meaningful Interaction Story"
  end
end
