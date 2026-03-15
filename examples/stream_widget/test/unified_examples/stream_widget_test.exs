defmodule UnifiedExamples.StreamWidgetTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.StreamWidget

  test "stream widget example exposes standalone example metadata" do
    assert StreamWidget.metadata() == %{
             id: :stream_widget_example_screen,
             root_id: :stream_widget_example_screen_root,
             title: "Stream Widget Example",
             summary: "Focused operational example using the shared suite shell",
             notes:
               "Stream-widget examples foreground one canonical append-only operations feed inside the shared shell.",
             widget: :stream_widget,
             theme_id: :example_suite_default,
             app: :unified_example_stream_widget,
             directory: "examples/stream_widget",
             purpose: :widget_proof
           }
  end

  test "stream widget example renders the shared shell and foregrounds one primary feed" do
    assert {:ok, runtime_state} = StreamWidget.boot()
    assert {:ok, html} = StreamWidget.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :stream_widget_example_screen_shell

    assert %UnifiedIUR.Element{kind: :stream_widget} =
             Tree.find_by_id(
               runtime_state.assigns.iur,
               :stream_widget_example_primary_stream_widget
             )

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"stream-widget\""
    assert html =~ "Stream Widget Example"
    assert html =~ "Queue latency crossed the warning threshold"
  end
end
