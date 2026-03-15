defmodule UnifiedExamples.MarkdownViewerTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.MarkdownViewer

  test "markdown viewer example exposes standalone example metadata" do
    assert MarkdownViewer.metadata() == %{
             id: :markdown_viewer_example_screen,
             root_id: :markdown_viewer_example_screen_root,
             title: "Markdown Viewer Widget Example",
             summary: "Focused data-oriented example using the shared suite shell",
             notes:
               "Markdown viewer examples foreground one canonical document surface inside the shared shell.",
             widget: :markdown_viewer,
             theme_id: :example_suite_default,
             app: :unified_example_markdown_viewer,
             directory: "examples/markdown_viewer",
             purpose: :widget_proof
           }
  end

  test "markdown viewer example renders the shared shell and foregrounds one primary document" do
    assert {:ok, runtime_state} = MarkdownViewer.boot()
    assert {:ok, html} = MarkdownViewer.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :markdown_viewer_example_screen_shell

    assert %UnifiedIUR.Element{kind: :markdown_viewer} =
             Tree.find_by_id(runtime_state.assigns.iur, :markdown_viewer_example_primary_document)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"markdown-viewer\""
    assert html =~ "Markdown Viewer Widget Example"
    assert html =~ "Incident Summary"
    assert html =~ "Primary system: API"
  end
end
