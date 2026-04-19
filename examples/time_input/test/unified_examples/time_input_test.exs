defmodule UnifiedExamples.TimeInputTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.TimeInput
  alias UnifiedExamples.TimeInput.Screen

  @endpoint UnifiedExamples.TimeInput.Endpoint

  test "time_input example exposes self-contained example metadata" do
    metadata = TimeInput.metadata()

    assert metadata.id == :time_input_example_screen
    assert metadata.root_id == :time_input_example_screen_root
    assert metadata.title == "Time Input Widget Example"
    assert metadata.summary == "Focused input-oriented example using the local example shell"
    assert metadata.notes == "Time input examples keep the local form shell while foregrounding one time control."
    assert metadata.widget == :time_input
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_time_input
    assert metadata.directory == "examples/time_input"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.TimeInput.Application,
             UnifiedExamples.TimeInput.Endpoint,
             UnifiedExamples.TimeInput.Router,
             UnifiedExamples.TimeInput.Layouts,
             UnifiedExamples.TimeInput.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.TimeInput.Screen,
             UnifiedExamples.TimeInput.Theme,
             UnifiedExamples.TimeInput.StyleProfile,
             UnifiedExamples.TimeInput.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "time_input example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = TimeInput.boot()
    assert {:ok, html} = TimeInput.render_html()

    assert runtime_state.assigns.iur.id == :time_input_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Time Input Widget Example"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "type=\"time\""
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_change_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "time_input example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/time_input\""
    assert body =~ "Time Input Widget Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
