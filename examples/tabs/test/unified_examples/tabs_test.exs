defmodule UnifiedExamples.TabsTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Tabs
  alias UnifiedExamples.Tabs.Screen

  @endpoint UnifiedExamples.Tabs.Endpoint

  test "tabs example exposes self-contained example metadata" do
    metadata = Tabs.metadata()

    assert metadata.id == :tabs_example_screen
    assert metadata.root_id == :tabs_example_screen_root
    assert metadata.title == "Tabs Widget Example"
    assert metadata.summary == "Focused navigation-oriented example using the local example shell"
    assert metadata.notes == "Tabs examples keep the local shell while foregrounding one canonical view switcher."
    assert metadata.widget == :tabs
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_tabs
    assert metadata.directory == "examples/tabs"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Tabs.Application,
             UnifiedExamples.Tabs.Endpoint,
             UnifiedExamples.Tabs.Router,
             UnifiedExamples.Tabs.Layouts,
             UnifiedExamples.Tabs.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Tabs.Screen,
             UnifiedExamples.Tabs.Theme,
             UnifiedExamples.Tabs.StyleProfile,
             UnifiedExamples.Tabs.Helpers
           ]
    assert metadata.style_contract.component_style_ids == [
             :example_shell,
             :example_panel,
             :example_form_shell,
             :example_title,
             :example_summary,
             :example_notes,
             :example_primary_button,
             :example_primary_input
           ]
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :navigation
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "tabs example renders the local shell and foregrounds one primary tab set" do
    assert {:ok, runtime_state} = Tabs.boot()
    assert {:ok, html} = Tabs.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :tabs_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"tabs\""
    assert html =~ "Tabs Widget Example"
    assert html =~ "Summary"
    assert html =~ "Deploys"
    assert html =~ "Alerts"
    assert html =~ "Review the tabs navigation story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "tabs example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/tabs\""
    assert body =~ "Tabs Widget Example"
    assert body =~ "data-live-ui-widget=\"tabs\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
