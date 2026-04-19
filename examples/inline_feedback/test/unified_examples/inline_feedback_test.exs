defmodule UnifiedExamples.InlineFeedbackTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.InlineFeedback
  alias UnifiedExamples.InlineFeedback.Screen

  @endpoint UnifiedExamples.InlineFeedback.Endpoint

  test "inline feedback example exposes self-contained example metadata" do
    metadata = InlineFeedback.metadata()

    assert metadata.id == :inline_feedback_example_screen
    assert metadata.root_id == :inline_feedback_example_screen_root
    assert metadata.title == "Inline Feedback Widget Example"
    assert metadata.summary == "Focused feedback-oriented example using the local example shell"
    assert metadata.notes == "Inline feedback examples foreground one canonical inline message surface inside the local shell."
    assert metadata.widget == :inline_feedback
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_inline_feedback
    assert metadata.directory == "examples/inline_feedback"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.InlineFeedback.Application,
             UnifiedExamples.InlineFeedback.Endpoint,
             UnifiedExamples.InlineFeedback.Router,
             UnifiedExamples.InlineFeedback.Layouts,
             UnifiedExamples.InlineFeedback.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.InlineFeedback.Screen,
             UnifiedExamples.InlineFeedback.Theme,
             UnifiedExamples.InlineFeedback.StyleProfile,
             UnifiedExamples.InlineFeedback.Helpers
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

  test "inline feedback example renders the local shell and foregrounds one primary feedback message" do
    assert {:ok, runtime_state} = InlineFeedback.boot()
    assert {:ok, html} = InlineFeedback.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :inline_feedback_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"inline-feedback\""
    assert html =~ "Inline Feedback Widget Example"
    assert html =~ "Validation complete"
    assert html =~ "Runbook synced across regions"
    assert html =~ "Inspect the inline feedback feedback story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "inline feedback example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/inline_feedback\""
    assert body =~ "Inline Feedback Widget Example"
    assert body =~ "data-live-ui-widget=\"inline-feedback\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
