defmodule UnifiedExamples.StreamWidgetTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.StreamWidget
  alias UnifiedExamples.StreamWidget.Screen

  @endpoint UnifiedExamples.StreamWidget.Endpoint

  test "stream-widget example exposes self-contained example metadata" do
    metadata = StreamWidget.metadata()

    assert metadata.id == :stream_widget_example_screen
    assert metadata.root_id == :stream_widget_example_screen_root
    assert metadata.title == "Stream Widget Example"
    assert metadata.summary == "Focused operational example using the local example shell"
    assert metadata.notes == "Stream-widget examples foreground one canonical append-only operations feed inside the local shell."
    assert metadata.widget == :stream_widget
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_stream_widget
    assert metadata.directory == "examples/stream_widget"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.StreamWidget.Application,
             UnifiedExamples.StreamWidget.Endpoint,
             UnifiedExamples.StreamWidget.Router,
             UnifiedExamples.StreamWidget.Layouts,
             UnifiedExamples.StreamWidget.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.StreamWidget.Screen,
             UnifiedExamples.StreamWidget.Theme,
             UnifiedExamples.StreamWidget.StyleProfile,
             UnifiedExamples.StreamWidget.Helpers
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
    assert metadata.interaction_demo.family == :command
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "stream-widget example renders the local shell and foregrounds one primary stream widget" do
    assert {:ok, runtime_state} = StreamWidget.boot()
    assert {:ok, html} = StreamWidget.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :stream_widget_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"stream-widget\""
    assert html =~ "Stream Widget Example"
    assert html =~ "Queue latency crossed the warning threshold"
    assert html =~ "Inspect the stream widget monitoring story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "stream-widget example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/stream_widget\""
    assert body =~ "Stream Widget Example"
    assert body =~ "data-live-ui-widget=\"stream-widget\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
