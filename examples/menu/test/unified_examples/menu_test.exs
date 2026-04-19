defmodule UnifiedExamples.MenuTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Menu
  alias UnifiedExamples.Menu.Screen

  @endpoint UnifiedExamples.Menu.Endpoint

  test "menu example exposes self-contained example metadata" do
    metadata = Menu.metadata()

    assert metadata.id == :menu_example_screen
    assert metadata.root_id == :menu_example_screen_root
    assert metadata.title == "Menu Widget Example"
    assert metadata.summary == "Focused navigation-oriented example using the local example shell"
    assert metadata.notes == "Menu examples foreground one canonical navigation rail inside the local shell."
    assert metadata.widget == :menu
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_menu
    assert metadata.directory == "examples/menu"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Menu.Application,
             UnifiedExamples.Menu.Endpoint,
             UnifiedExamples.Menu.Router,
             UnifiedExamples.Menu.Layouts,
             UnifiedExamples.Menu.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Menu.Screen,
             UnifiedExamples.Menu.Theme,
             UnifiedExamples.Menu.StyleProfile,
             UnifiedExamples.Menu.Helpers
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

  test "menu example renders the local shell and foregrounds one primary menu" do
    assert {:ok, runtime_state} = Menu.boot()
    assert {:ok, html} = Menu.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :menu_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"menu\""
    assert html =~ "Menu Widget Example"
    assert html =~ "Overview"
    assert html =~ "Incidents"
    assert html =~ "Releases"
    assert html =~ "Review the menu navigation story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "menu example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/menu\""
    assert body =~ "Menu Widget Example"
    assert body =~ "data-live-ui-widget=\"menu\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
