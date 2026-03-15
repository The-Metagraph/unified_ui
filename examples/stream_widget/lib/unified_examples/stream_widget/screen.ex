defmodule UnifiedExamples.StreamWidget.Screen do
  @moduledoc """
  Shared-template stream-widget proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @stream_entries Fixtures.stream_widget_entries()

  use UnifiedExamples.Shared.Template,
    id: :stream_widget_example_screen,
    title: "Stream Widget Example",
    summary: "Focused operational example using the shared suite shell",
    widget: :stream_widget,
    notes:
      "Stream-widget examples foreground one canonical append-only operations feed inside the shared shell."

  example_panel do
    stream_widget :stream_widget_example_primary_stream_widget do
      entries(@stream_entries)
      ordering(:append_only)
      severity_field(:severity)
      timestamp_field(:timestamp)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
