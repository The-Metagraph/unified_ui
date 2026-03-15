defmodule UnifiedExamples.BarChartTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.BarChart

  test "bar chart example exposes standalone example metadata" do
    assert BarChart.metadata() == %{
             id: :bar_chart_example_screen,
             root_id: :bar_chart_example_screen_root,
             title: "Bar Chart Widget Example",
             summary: "Focused feedback-oriented example using the shared suite shell",
             notes:
               "Bar chart examples foreground one canonical categorical chart inside the shared shell.",
             widget: :bar_chart,
             theme_id: :example_suite_default,
             app: :unified_example_bar_chart,
             directory: "examples/bar_chart",
             purpose: :widget_proof
           }
  end

  test "bar chart example renders the shared shell and foregrounds one primary bar chart" do
    assert {:ok, runtime_state} = BarChart.boot()
    assert {:ok, html} = BarChart.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :bar_chart_example_screen_shell

    assert %UnifiedIUR.Element{kind: :bar_chart} =
             Tree.find_by_id(runtime_state.assigns.iur, :bar_chart_example_primary_chart)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"bar-chart\""
    assert html =~ "Bar Chart Widget Example"
    assert html =~ "API"
  end
end
