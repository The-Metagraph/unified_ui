defmodule UnifiedExamples.GaugeTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Gauge
  alias UnifiedExamples.Gauge.Screen

  @endpoint UnifiedExamples.Gauge.Endpoint

  test "gauge example exposes self-contained example metadata" do
    metadata = Gauge.metadata()

    assert metadata.id == :gauge_example_screen
    assert metadata.root_id == :gauge_example_screen_root
    assert metadata.title == "Gauge Widget Example"
    assert metadata.summary == "Focused feedback-oriented example using the local example shell"
    assert metadata.notes == "Gauge examples foreground one canonical measurement widget inside the local shell."
    assert metadata.widget == :gauge
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_gauge
    assert metadata.directory == "examples/gauge"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Gauge.Application,
             UnifiedExamples.Gauge.Endpoint,
             UnifiedExamples.Gauge.Router,
             UnifiedExamples.Gauge.Layouts,
             UnifiedExamples.Gauge.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Gauge.Screen,
             UnifiedExamples.Gauge.Theme,
             UnifiedExamples.Gauge.StyleProfile,
             UnifiedExamples.Gauge.Helpers
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

  test "gauge example renders the local shell and foregrounds one primary gauge" do
    assert {:ok, runtime_state} = Gauge.boot()
    assert {:ok, html} = Gauge.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :gauge_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"gauge\""
    assert html =~ "Gauge Widget Example"
    assert html =~ "CPU load"
    assert html =~ "74"
    assert html =~ "Inspect the gauge feedback story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "gauge example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/gauge\""
    assert body =~ "Gauge Widget Example"
    assert body =~ "data-live-ui-widget=\"gauge\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
