defmodule UnifiedExamples.ProgressTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Progress
  alias UnifiedExamples.Progress.Screen

  @endpoint UnifiedExamples.Progress.Endpoint

  test "progress example exposes self-contained example metadata" do
    metadata = Progress.metadata()

    assert metadata.id == :progress_example_screen
    assert metadata.root_id == :progress_example_screen_root
    assert metadata.title == "Progress Widget Example"
    assert metadata.summary == "Focused feedback-oriented example using the local example shell"
    assert metadata.notes == "Progress examples foreground one canonical progress indicator inside the local shell."
    assert metadata.widget == :progress
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_progress
    assert metadata.directory == "examples/progress"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Progress.Application,
             UnifiedExamples.Progress.Endpoint,
             UnifiedExamples.Progress.Router,
             UnifiedExamples.Progress.Layouts,
             UnifiedExamples.Progress.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Progress.Screen,
             UnifiedExamples.Progress.Theme,
             UnifiedExamples.Progress.StyleProfile,
             UnifiedExamples.Progress.Helpers
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

  test "progress example renders the local shell and foregrounds one primary progress indicator" do
    assert {:ok, runtime_state} = Progress.boot()
    assert {:ok, html} = Progress.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :progress_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"progress\""
    assert html =~ "Progress Widget Example"
    assert html =~ "Deploy progress"
    assert html =~ "Inspect the progress feedback story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "progress example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/progress\""
    assert body =~ "Progress Widget Example"
    assert body =~ "data-live-ui-widget=\"progress\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
