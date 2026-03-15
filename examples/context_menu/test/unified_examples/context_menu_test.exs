defmodule UnifiedExamples.ContextMenuTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.ContextMenu

  test "context menu example exposes standalone example metadata" do
    assert ContextMenu.metadata() == %{
             id: :context_menu_example_screen,
             root_id: :context_menu_example_screen_root,
             title: "Context Menu Widget Example",
             summary: "Focused overlay example using the shared suite shell",
             notes:
               "Context-menu examples foreground one canonical anchored action menu inside the shared shell.",
             widget: :context_menu,
             theme_id: :example_suite_default,
             app: :unified_example_context_menu,
             directory: "examples/context_menu",
             purpose: :widget_proof
           }
  end

  test "context menu example renders the shared shell and foregrounds one primary context menu" do
    assert {:ok, runtime_state} = ContextMenu.boot()
    assert {:ok, html} = ContextMenu.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :context_menu_example_screen_shell

    assert %UnifiedIUR.Element{kind: :context_menu} =
             Tree.find_by_id(
               runtime_state.assigns.iur,
               :context_menu_example_primary_context_menu
             )

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"context-menu\""
    assert html =~ "Context Menu Widget Example"
    assert html =~ "Retry sync"
  end
end
