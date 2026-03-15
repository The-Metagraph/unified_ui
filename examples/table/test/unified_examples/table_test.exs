defmodule UnifiedExamples.TableTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Table

  test "table example exposes standalone example metadata" do
    assert Table.metadata() == %{
             id: :table_example_screen,
             root_id: :table_example_screen_root,
             title: "Table Widget Example",
             summary: "Focused data-oriented example using the shared suite shell",
             notes:
               "Table examples foreground one canonical tabular dataset inside the shared shell.",
             widget: :table,
             theme_id: :example_suite_default,
             app: :unified_example_table,
             directory: "examples/table",
             purpose: :widget_proof
           }
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
  end
end
