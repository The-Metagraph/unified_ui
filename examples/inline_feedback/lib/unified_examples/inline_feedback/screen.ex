defmodule UnifiedExamples.InlineFeedback.Screen do
  @moduledoc """
  Shared-template inline-feedback proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @inline_feedback_snapshot Fixtures.inline_feedback_snapshot()
  @inline_feedback_title @inline_feedback_snapshot.title
  @inline_feedback_message @inline_feedback_snapshot.message
  @inline_feedback_severity @inline_feedback_snapshot.severity
  @inline_feedback_status @inline_feedback_snapshot.status

  use UnifiedExamples.Shared.Template,
    id: :inline_feedback_example_screen,
    title: "Inline Feedback Widget Example",
    summary: "Focused feedback-oriented example using the shared suite shell",
    widget: :inline_feedback,
    notes:
      "Inline feedback examples foreground one canonical inline message surface inside the shared shell."

  example_panel do
    inline_feedback :inline_feedback_example_primary_feedback do
      title(@inline_feedback_title)
      message(@inline_feedback_message)
      severity(@inline_feedback_severity)
      status(@inline_feedback_status)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
