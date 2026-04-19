defmodule UnifiedExamples.FileInputTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.FileInput
  alias UnifiedExamples.FileInput.Screen

  @endpoint UnifiedExamples.FileInput.Endpoint

  test "file_input example exposes self-contained example metadata" do
    metadata = FileInput.metadata()

    assert metadata.id == :file_input_example_screen
    assert metadata.root_id == :file_input_example_screen_root
    assert metadata.title == "File Input Widget Example"
    assert metadata.summary == "Focused input-oriented example using the local example shell"
    assert metadata.notes == "File input examples keep the local form shell while foregrounding one file picker control."
    assert metadata.widget == :file_input
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_file_input
    assert metadata.directory == "examples/file_input"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.FileInput.Application,
             UnifiedExamples.FileInput.Endpoint,
             UnifiedExamples.FileInput.Router,
             UnifiedExamples.FileInput.Layouts,
             UnifiedExamples.FileInput.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.FileInput.Screen,
             UnifiedExamples.FileInput.Theme,
             UnifiedExamples.FileInput.StyleProfile,
             UnifiedExamples.FileInput.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "file_input example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = FileInput.boot()
    assert {:ok, html} = FileInput.render_html()

    assert runtime_state.assigns.iur.id == :file_input_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "File Input Widget Example"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "type=\"file\""
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_change_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "file_input example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/file_input\""
    assert body =~ "File Input Widget Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
