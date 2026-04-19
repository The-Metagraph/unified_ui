defmodule UnifiedExamples.NumericInputTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.NumericInput
  alias UnifiedExamples.NumericInput.Screen

  @endpoint UnifiedExamples.NumericInput.Endpoint

  test "numeric_input example exposes self-contained example metadata" do
    metadata = NumericInput.metadata()

    assert metadata.id == :numeric_input_example_screen
    assert metadata.root_id == :numeric_input_example_screen_root
    assert metadata.title == "Numeric Input Widget Example"
    assert metadata.summary == "Focused input-oriented example using the local example shell"
    assert metadata.notes == "Numeric input examples keep the local form shell while foregrounding one numeric control."
    assert metadata.widget == :numeric_input
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_numeric_input
    assert metadata.directory == "examples/numeric_input"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.NumericInput.Application,
             UnifiedExamples.NumericInput.Endpoint,
             UnifiedExamples.NumericInput.Router,
             UnifiedExamples.NumericInput.Layouts,
             UnifiedExamples.NumericInput.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.NumericInput.Screen,
             UnifiedExamples.NumericInput.Theme,
             UnifiedExamples.NumericInput.StyleProfile,
             UnifiedExamples.NumericInput.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "numeric_input example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = NumericInput.boot()
    assert {:ok, html} = NumericInput.render_html()

    assert runtime_state.assigns.iur.id == :numeric_input_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Numeric Input Widget Example"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "type=\"number\""
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_change_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "numeric_input example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/numeric_input\""
    assert body =~ "Numeric Input Widget Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
