defmodule UnifiedExamples.ColumnTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Column
  alias UnifiedExamples.Column.Screen

  @endpoint UnifiedExamples.Column.Endpoint

  test "column example exposes self-contained example metadata" do
    metadata = Column.metadata()

    assert metadata.id == :column_example_screen
    assert metadata.root_id == :column_example_screen_root
    assert metadata.title == "Column Widget Example"
    assert metadata.summary == "Focused layout-oriented example using the local example shell"
    assert metadata.notes == "Column examples keep the local shell while foregrounding one vertical layout flow."
    assert metadata.widget == :column
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_column
    assert metadata.directory == "examples/column"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Column.Application,
             UnifiedExamples.Column.Endpoint,
             UnifiedExamples.Column.Router,
             UnifiedExamples.Column.Layouts,
             UnifiedExamples.Column.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Column.Screen,
             UnifiedExamples.Column.Theme,
             UnifiedExamples.Column.StyleProfile,
             UnifiedExamples.Column.Helpers
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

  test "column example renders the local shell and foregrounds one primary column" do
    assert {:ok, runtime_state} = Column.boot()
    assert {:ok, html} = Column.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :column_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"column\""
    assert html =~ "Column Widget Example"
    assert html =~ "On-call checklist"
    assert html =~ "Acknowledge"
    assert html =~ "Review the column layout story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "column example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/column\""
    assert body =~ "Column Widget Example"
    assert body =~ "data-live-ui-widget=\"column\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
