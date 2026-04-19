defmodule UnifiedExamples.RowTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Row
  alias UnifiedExamples.Row.Screen

  @endpoint UnifiedExamples.Row.Endpoint

  test "row example exposes self-contained example metadata" do
    metadata = Row.metadata()

    assert metadata.id == :row_example_screen
    assert metadata.root_id == :row_example_screen_root
    assert metadata.title == "Row Widget Example"
    assert metadata.summary == "Focused layout-oriented example using the local example shell"
    assert metadata.notes == "Row examples keep the local shell while foregrounding one horizontal layout flow."
    assert metadata.widget == :row
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_row
    assert metadata.directory == "examples/row"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Row.Application,
             UnifiedExamples.Row.Endpoint,
             UnifiedExamples.Row.Router,
             UnifiedExamples.Row.Layouts,
             UnifiedExamples.Row.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Row.Screen,
             UnifiedExamples.Row.Theme,
             UnifiedExamples.Row.StyleProfile,
             UnifiedExamples.Row.Helpers
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
    assert metadata.interaction_demo.family == :click
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "row example renders the local shell and foregrounds one primary row" do
    assert {:ok, runtime_state} = Row.boot()
    assert {:ok, html} = Row.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :row_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"row\""
    assert html =~ "Row Widget Example"
    assert html =~ "Release train"
    assert html =~ "Queue active"
    assert html =~ "Review"
    assert html =~ "Review the row layout story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "row example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/row\""
    assert body =~ "Row Widget Example"
    assert body =~ "data-live-ui-widget=\"row\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
