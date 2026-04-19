defmodule UnifiedExamples.ScrollBarTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.ScrollBar
  alias UnifiedExamples.ScrollBar.Screen

  @endpoint UnifiedExamples.ScrollBar.Endpoint

  test "scroll bar example exposes self-contained example metadata" do
    metadata = ScrollBar.metadata()

    assert metadata.id == :scroll_bar_example_screen
    assert metadata.root_id == :scroll_bar_example_screen_root
    assert metadata.title == "Scroll Bar Widget Example"
    assert metadata.summary == "Focused display-system example using the local example shell"
    assert metadata.notes == "Scroll-bar examples foreground one canonical viewport control inside the local shell."
    assert metadata.widget == :scroll_bar
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_scroll_bar
    assert metadata.directory == "examples/scroll_bar"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.ScrollBar.Application,
             UnifiedExamples.ScrollBar.Endpoint,
             UnifiedExamples.ScrollBar.Router,
             UnifiedExamples.ScrollBar.Layouts,
             UnifiedExamples.ScrollBar.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.ScrollBar.Screen,
             UnifiedExamples.ScrollBar.Theme,
             UnifiedExamples.ScrollBar.StyleProfile,
             UnifiedExamples.ScrollBar.Helpers
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
    assert metadata.interaction_demo.family == :focus
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "scroll bar example renders the local shell and foregrounds one primary scroll bar" do
    assert {:ok, runtime_state} = ScrollBar.boot()
    assert {:ok, html} = ScrollBar.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :scroll_bar_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"scroll-bar\""
    assert html =~ "Scroll Bar Widget Example"
    assert html =~ "Scrollable incident log"
    assert html =~ "Inspect the scroll bar display story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "scroll bar example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/scroll_bar\""
    assert body =~ "Scroll Bar Widget Example"
    assert body =~ "data-live-ui-widget=\"scroll-bar\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
