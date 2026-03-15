defmodule UnifiedExamples.LabelTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Label

  test "label example exposes standalone example metadata" do
    assert Label.metadata() == %{
             id: :label_example_screen,
             root_id: :label_example_screen_root,
             title: "Label Widget Example",
             summary: "Focused content-oriented example using the shared suite shell",
             notes:
               "Label examples keep the shared shell while foregrounding one primary label widget.",
             widget: :label,
             theme_id: :example_suite_default,
             app: :unified_example_label,
             directory: "examples/label",
             purpose: :widget_proof
           }
  end

  test "label example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Label.boot()
    assert {:ok, html} = Label.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :label_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Label Widget Example"
    assert html =~ "Assigned owner"
    assert html =~ "data-live-ui-widget=\"label\""
    assert html =~ "data-live-ui-variant=\"body\""
  end
end
