defmodule UnifiedExamples.ListTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.List

  test "list example exposes standalone example metadata" do
    assert List.metadata() == %{
             id: :list_example_screen,
             root_id: :list_example_screen_root,
             title: "List Widget Example",
             summary: "Focused data-oriented example using the shared suite shell",
             notes: "List examples foreground one canonical data list inside the shared shell.",
             widget: :list,
             theme_id: :example_suite_default,
             app: :unified_example_list,
             directory: "examples/list",
             purpose: :widget_proof
           }
  end

  test "list example renders the shared shell and foregrounds one primary list" do
    assert {:ok, runtime_state} = List.boot()
    assert {:ok, html} = List.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :list_example_screen_shell

    assert %UnifiedIUR.Element{kind: :list} =
             Tree.find_by_id(runtime_state.assigns.iur, :list_example_primary_list)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"list\""
    assert html =~ "List Widget Example"
    assert html =~ "Database failover"
    assert html =~ "Queue backlog"
    assert html =~ "Docs refresh"
  end
end
