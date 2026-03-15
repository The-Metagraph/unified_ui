defmodule UnifiedExamples.TimeInputTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.TimeInput

  test "time_input example exposes standalone example metadata" do
    assert TimeInput.metadata() == %{
             id: :time_input_example_screen,
             root_id: :time_input_example_screen_root,
             title: "Time Input Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Time input examples keep the shared form shell while foregrounding one time control.",
             widget: :time_input,
             theme_id: :example_suite_default,
             app: :unified_example_time_input,
             directory: "examples/time_input",
             purpose: :widget_proof
           }
  end

  test "time_input example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = TimeInput.boot()
    assert {:ok, html} = TimeInput.render_html()

    assert runtime_state.assigns.iur.id == :time_input_example_screen_shell

    assert %UnifiedIUR.Element{kind: :time_input} =
             Tree.find_by_id(runtime_state.assigns.iur, :time_input_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Time Input Widget Example"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "type=\"time\""
    assert html =~ "data-live-ui-variant=\"filled\""
  end
end
