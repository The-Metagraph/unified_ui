defmodule UnifiedExamples.DateInputTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.DateInput
  alias UnifiedExamples.DateInput.Screen

  @endpoint UnifiedExamples.DateInput.Endpoint

  test "date_input example exposes self-contained example metadata" do
    metadata = DateInput.metadata()

    assert metadata.id == :date_input_example_screen
    assert metadata.root_id == :date_input_example_screen_root
    assert metadata.title == "Date Input Widget Example"
    assert metadata.summary == "Focused input-oriented example using the local example shell"
    assert metadata.notes == "Date input examples keep the local form shell while foregrounding one date control."
    assert metadata.widget == :date_input
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_date_input
    assert metadata.directory == "examples/date_input"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.DateInput.Application,
             UnifiedExamples.DateInput.Endpoint,
             UnifiedExamples.DateInput.Router,
             UnifiedExamples.DateInput.Layouts,
             UnifiedExamples.DateInput.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.DateInput.Screen,
             UnifiedExamples.DateInput.Theme,
             UnifiedExamples.DateInput.StyleProfile,
             UnifiedExamples.DateInput.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "date_input example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = DateInput.boot()
    assert {:ok, html} = DateInput.render_html()

    assert runtime_state.assigns.iur.id == :date_input_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Date Input Widget Example"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "type=\"date\""
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_change_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "date_input example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/date_input\""
    assert body =~ "Date Input Widget Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
