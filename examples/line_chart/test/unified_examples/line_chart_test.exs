defmodule UnifiedExamples.LineChartTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.LineChart

  test "line chart example exposes standalone example metadata" do
    assert LineChart.metadata() == %{
             id: :line_chart_example_screen,
             root_id: :line_chart_example_screen_root,
             title: "Line Chart Widget Example",
             summary: "Focused feedback-oriented example using the shared suite shell",
             notes:
               "Line chart examples foreground one canonical time-series chart inside the shared shell.",
             widget: :line_chart,
             theme_id: :example_suite_default,
             app: :unified_example_line_chart,
             directory: "examples/line_chart",
             purpose: :widget_proof
           }
  end

  test "line chart example renders the shared shell and foregrounds one primary line chart" do
    assert {:ok, runtime_state} = LineChart.boot()
    assert {:ok, html} = LineChart.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :line_chart_example_screen_shell

    assert %UnifiedIUR.Element{kind: :line_chart} =
             Tree.find_by_id(runtime_state.assigns.iur, :line_chart_example_primary_chart)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"line-chart\""
    assert html =~ "Line Chart Widget Example"
  end
end
