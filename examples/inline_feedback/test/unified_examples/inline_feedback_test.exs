defmodule UnifiedExamples.InlineFeedbackTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.InlineFeedback

  test "inline feedback example exposes standalone example metadata" do
    assert InlineFeedback.metadata() == %{
             id: :inline_feedback_example_screen,
             root_id: :inline_feedback_example_screen_root,
             title: "Inline Feedback Widget Example",
             summary: "Focused feedback-oriented example using the shared suite shell",
             notes:
               "Inline feedback examples foreground one canonical inline message surface inside the shared shell.",
             widget: :inline_feedback,
             theme_id: :example_suite_default,
             app: :unified_example_inline_feedback,
             directory: "examples/inline_feedback",
             purpose: :widget_proof
           }
  end

  test "inline feedback example renders the shared shell and foregrounds one primary feedback message" do
    assert {:ok, runtime_state} = InlineFeedback.boot()
    assert {:ok, html} = InlineFeedback.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :inline_feedback_example_screen_shell

    assert %UnifiedIUR.Element{kind: :inline_feedback} =
             Tree.find_by_id(
               runtime_state.assigns.iur,
               :inline_feedback_example_primary_feedback
             )

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"inline-feedback\""
    assert html =~ "Inline Feedback Widget Example"
    assert html =~ "Validation complete"
    assert html =~ "Runbook synced across regions"
  end
end
