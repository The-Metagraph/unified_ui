defmodule UnifiedExamples.LineChartTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.LineChart
  alias UnifiedExamples.LineChart.Screen

  @endpoint UnifiedExamples.LineChart.Endpoint

  test "line chart example exposes self-contained example metadata" do
    metadata = LineChart.metadata()

    assert metadata.id == :line_chart_example_screen
    assert metadata.root_id == :line_chart_example_screen_root
    assert metadata.title == "Line Chart Widget Example"
    assert metadata.summary == "Focused feedback-oriented example using the local example shell"
    assert metadata.notes == "Line chart examples foreground one canonical time-series chart inside the local shell."
    assert metadata.widget == :line_chart
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_line_chart
    assert metadata.directory == "examples/line_chart"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.LineChart.Application,
             UnifiedExamples.LineChart.Endpoint,
             UnifiedExamples.LineChart.Router,
             UnifiedExamples.LineChart.Layouts,
             UnifiedExamples.LineChart.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.LineChart.Screen,
             UnifiedExamples.LineChart.Theme,
             UnifiedExamples.LineChart.StyleProfile,
             UnifiedExamples.LineChart.Helpers
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

  test "line chart example renders the local shell and foregrounds one primary line chart" do
    assert {:ok, runtime_state} = LineChart.boot()
    assert {:ok, html} = LineChart.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :line_chart_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"line-chart\""
    assert html =~ "Line Chart Widget Example"
    assert html =~ "Inspect the line chart feedback story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "line chart example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/line_chart\""
    assert body =~ "Line Chart Widget Example"
    assert body =~ "data-live-ui-widget=\"line-chart\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
