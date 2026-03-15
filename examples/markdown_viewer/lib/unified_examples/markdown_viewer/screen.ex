defmodule UnifiedExamples.MarkdownViewer.Screen do
  @moduledoc """
  Shared-template markdown-viewer proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  use UnifiedExamples.Shared.Template,
    id: :markdown_viewer_example_screen,
    title: "Markdown Viewer Widget Example",
    summary: "Focused data-oriented example using the shared suite shell",
    widget: :markdown_viewer,
    notes:
      "Markdown viewer examples foreground one canonical document surface inside the shared shell."

  example_panel do
    markdown_viewer :markdown_viewer_example_primary_document do
      source(Fixtures.incident_markdown())
      presentation(:rendered)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
