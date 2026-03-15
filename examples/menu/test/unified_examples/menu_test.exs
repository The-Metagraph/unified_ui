defmodule UnifiedExamples.MenuTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Menu

  test "menu example exposes standalone example metadata" do
    assert Menu.metadata() == %{
             id: :menu_example_screen,
             root_id: :menu_example_screen_root,
             title: "Menu Widget Example",
             summary: "Focused navigation-oriented example using the shared suite shell",
             notes:
               "Menu examples foreground one canonical navigation rail inside the shared shell.",
             widget: :menu,
             theme_id: :example_suite_default,
             app: :unified_example_menu,
             directory: "examples/menu",
             purpose: :widget_proof
           }
  end

  test "menu example renders the shared shell and foregrounds one primary menu" do
    assert {:ok, runtime_state} = Menu.boot()
    assert {:ok, html} = Menu.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :menu_example_screen_shell

    assert %UnifiedIUR.Element{kind: :menu} =
             Tree.find_by_id(runtime_state.assigns.iur, :menu_example_primary_menu)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"menu\""
    assert html =~ "Menu Widget Example"
    assert html =~ "Overview"
    assert html =~ "Incidents"
    assert html =~ "Releases"
  end
end
