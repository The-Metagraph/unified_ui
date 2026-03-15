defmodule UnifiedExamples.MarkdownViewer do
  @moduledoc """
  Standalone markdown viewer example-app entrypoint for the shared examples suite.
  """

  use UnifiedExamples.Shared.App,
    app: :unified_example_markdown_viewer,
    directory: "examples/markdown_viewer"
end
