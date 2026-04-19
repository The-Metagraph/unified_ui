defmodule UnifiedExamples.MarkdownViewerTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.MarkdownViewer
  alias UnifiedExamples.MarkdownViewer.Screen

  @endpoint UnifiedExamples.MarkdownViewer.Endpoint

  test "markdown viewer example exposes self-contained example metadata" do
    metadata = MarkdownViewer.metadata()

    assert metadata.id == :markdown_viewer_example_screen
    assert metadata.root_id == :markdown_viewer_example_screen_root
    assert metadata.title == "Markdown Viewer Widget Example"
    assert metadata.summary == "Focused data-oriented example using the local example shell"
    assert metadata.notes == "Markdown viewer examples foreground one canonical document surface inside the local shell."
    assert metadata.widget == :markdown_viewer
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_markdown_viewer
    assert metadata.directory == "examples/markdown_viewer"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.MarkdownViewer.Application,
             UnifiedExamples.MarkdownViewer.Endpoint,
             UnifiedExamples.MarkdownViewer.Router,
             UnifiedExamples.MarkdownViewer.Layouts,
             UnifiedExamples.MarkdownViewer.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.MarkdownViewer.Screen,
             UnifiedExamples.MarkdownViewer.Theme,
             UnifiedExamples.MarkdownViewer.StyleProfile,
             UnifiedExamples.MarkdownViewer.Helpers
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

  test "markdown viewer example renders the local shell and foregrounds one primary document" do
    assert {:ok, runtime_state} = MarkdownViewer.boot()
    assert {:ok, html} = MarkdownViewer.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :markdown_viewer_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"markdown-viewer\""
    assert html =~ "Markdown Viewer Widget Example"
    assert html =~ "Incident Summary"
    assert html =~ "Primary system: API"
    assert html =~ "Current status: Stable"
    assert html =~ "Inspect the markdown viewer data story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "markdown viewer example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/markdown_viewer\""
    assert body =~ "Markdown Viewer Widget Example"
    assert body =~ "data-live-ui-widget=\"markdown-viewer\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
