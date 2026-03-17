defmodule UnifiedExamples.MenuTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Menu

  test "menu example exposes standalone example metadata" do
    metadata = Menu.metadata()

    assert metadata.id == :menu_example_screen
    assert metadata.root_id == :menu_example_screen_root
    assert metadata.widget == :menu
    assert metadata.app == :unified_example_menu
    assert metadata.directory == "examples/menu"
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :navigation
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
    assert html =~ "Review the menu navigation story"
    assert html =~ "Meaningful Interaction Story"
  end
end
