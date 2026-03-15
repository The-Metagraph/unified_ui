defmodule UnifiedExamples.TabsTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Tabs

  test "tabs example exposes standalone example metadata" do
    assert Tabs.metadata() == %{
             id: :tabs_example_screen,
             root_id: :tabs_example_screen_root,
             title: "Tabs Widget Example",
             summary: "Focused navigation-oriented example using the shared suite shell",
             notes:
               "Tabs examples keep the shared shell while foregrounding one canonical view switcher.",
             widget: :tabs,
             theme_id: :example_suite_default,
             app: :unified_example_tabs,
             directory: "examples/tabs",
             purpose: :widget_proof
           }
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
