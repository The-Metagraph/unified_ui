defmodule UnifiedExamples.SparklineTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Sparkline
  alias UnifiedExamples.Sparkline.Screen

  @endpoint UnifiedExamples.Sparkline.Endpoint

  test "sparkline example exposes self-contained example metadata" do
    metadata = Sparkline.metadata()

    assert metadata.id == :sparkline_example_screen
    assert metadata.root_id == :sparkline_example_screen_root
    assert metadata.title == "Sparkline Widget Example"
    assert metadata.summary == "Focused feedback-oriented example using the local example shell"
    assert metadata.notes == "Sparkline examples foreground one canonical trend line inside the local shell."
    assert metadata.widget == :sparkline
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_sparkline
    assert metadata.directory == "examples/sparkline"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Sparkline.Application,
             UnifiedExamples.Sparkline.Endpoint,
             UnifiedExamples.Sparkline.Router,
             UnifiedExamples.Sparkline.Layouts,
             UnifiedExamples.Sparkline.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Sparkline.Screen,
             UnifiedExamples.Sparkline.Theme,
             UnifiedExamples.Sparkline.StyleProfile,
             UnifiedExamples.Sparkline.Helpers
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

  test "sparkline example renders the local shell and foregrounds one primary sparkline" do
    assert {:ok, runtime_state} = Sparkline.boot()
    assert {:ok, html} = Sparkline.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :sparkline_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"sparkline\""
    assert html =~ "Sparkline Widget Example"
    assert html =~ "Inspect the sparkline feedback story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "sparkline example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/sparkline\""
    assert body =~ "Sparkline Widget Example"
    assert body =~ "data-live-ui-widget=\"sparkline\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
