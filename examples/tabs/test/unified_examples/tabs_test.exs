defmodule UnifiedExamples.TabsTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Tabs

  test "tabs example exposes standalone example metadata" do
    metadata = Tabs.metadata()

    # Check core fields (interaction_demo is populated from defaults)
    assert metadata.id == :tabs_example_screen
    assert metadata.root_id == :tabs_example_screen_root
    assert metadata.title == "Tabs Widget Example"
    assert metadata.summary == "Focused navigation-oriented example using the shared suite shell"
    assert metadata.notes == "Tabs examples keep the shared shell while foregrounding one canonical view switcher."
    assert metadata.widget == :tabs
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_tabs
    assert metadata.directory == "examples/tabs"
    assert metadata.purpose == :widget_proof
  end

  test "tabs example renders the shared shell and foregrounds one primary tab set" do
    assert {:ok, runtime_state} = Tabs.boot()
    assert {:ok, html} = Tabs.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :tabs_example_screen_shell

    assert %UnifiedIUR.Element{kind: :tabs} =
             Tree.find_by_id(runtime_state.assigns.iur, :tabs_example_primary_tabs)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"tabs\""
    assert html =~ "Tabs Widget Example"
    assert html =~ "Summary"
    assert html =~ "Deploys"
    assert html =~ "Alerts"
  end
end
