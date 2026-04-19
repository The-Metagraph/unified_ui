defmodule UnifiedExamples.TableTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Table
  alias UnifiedExamples.Table.Screen

  @endpoint UnifiedExamples.Table.Endpoint

  test "table example exposes self-contained example metadata" do
    metadata = Table.metadata()

    assert metadata.id == :table_example_screen
    assert metadata.root_id == :table_example_screen_root
    assert metadata.title == "Table Widget Example"
    assert metadata.summary == "Focused data-oriented example using the local example shell"
    assert metadata.notes == "Table examples foreground one canonical tabular dataset inside the local shell."
    assert metadata.widget == :table
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_table
    assert metadata.directory == "examples/table"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Table.Application,
             UnifiedExamples.Table.Endpoint,
             UnifiedExamples.Table.Router,
             UnifiedExamples.Table.Layouts,
             UnifiedExamples.Table.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Table.Screen,
             UnifiedExamples.Table.Theme,
             UnifiedExamples.Table.StyleProfile,
             UnifiedExamples.Table.Helpers
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
    assert metadata.interaction_demo.family == :selection
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "table example renders the local shell and foregrounds one primary table" do
    assert {:ok, runtime_state} = Table.boot()
    assert {:ok, html} = Table.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :table_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"table\""
    assert html =~ "Table Widget Example"
    assert html =~ "API"
    assert html =~ "Healthy"
    assert html =~ "Platform"
    assert html =~ "Inspect the table data story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "table example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/table\""
    assert body =~ "Table Widget Example"
    assert body =~ "data-live-ui-widget=\"table\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
