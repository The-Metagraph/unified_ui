defmodule UnifiedExamples.GaugeTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Gauge

  test "gauge example exposes standalone example metadata" do
    assert Gauge.metadata() == %{
             id: :gauge_example_screen,
             root_id: :gauge_example_screen_root,
             title: "Gauge Widget Example",
             summary: "Focused feedback-oriented example using the shared suite shell",
             notes:
               "Gauge examples foreground one canonical measurement widget inside the shared shell.",
             widget: :gauge,
             theme_id: :example_suite_default,
             app: :unified_example_gauge,
             directory: "examples/gauge",
             purpose: :widget_proof
           }
  end

  test "gauge example renders the shared shell and foregrounds one primary gauge" do
    assert {:ok, runtime_state} = Gauge.boot()
    assert {:ok, html} = Gauge.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :gauge_example_screen_shell

    assert %UnifiedIUR.Element{kind: :gauge} =
             Tree.find_by_id(runtime_state.assigns.iur, :gauge_example_primary_gauge)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"gauge\""
    assert html =~ "Gauge Widget Example"
    assert html =~ "CPU load"
    assert html =~ "74"
  end
end
