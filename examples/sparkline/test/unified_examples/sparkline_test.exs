defmodule UnifiedExamples.SparklineTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Sparkline

  test "sparkline example exposes standalone example metadata" do
    assert Sparkline.metadata() == %{
             id: :sparkline_example_screen,
             root_id: :sparkline_example_screen_root,
             title: "Sparkline Widget Example",
             summary: "Focused feedback-oriented example using the shared suite shell",
             notes:
               "Sparkline examples foreground one canonical trend line inside the shared shell.",
             widget: :sparkline,
             theme_id: :example_suite_default,
             app: :unified_example_sparkline,
             directory: "examples/sparkline",
             purpose: :widget_proof
           }
  end

  test "sparkline example renders the shared shell and foregrounds one primary sparkline" do
    assert {:ok, runtime_state} = Sparkline.boot()
    assert {:ok, html} = Sparkline.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :sparkline_example_screen_shell

    assert %UnifiedIUR.Element{kind: :sparkline} =
             Tree.find_by_id(runtime_state.assigns.iur, :sparkline_example_primary_chart)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"sparkline\""
    assert html =~ "Sparkline Widget Example"
  end
end
