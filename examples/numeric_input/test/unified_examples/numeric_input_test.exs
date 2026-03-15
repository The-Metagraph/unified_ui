defmodule UnifiedExamples.NumericInputTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.NumericInput

  test "numeric_input example exposes standalone example metadata" do
    assert NumericInput.metadata() == %{
             id: :numeric_input_example_screen,
             root_id: :numeric_input_example_screen_root,
             title: "Numeric Input Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Numeric input examples keep the shared form shell while foregrounding one numeric control.",
             widget: :numeric_input,
             theme_id: :example_suite_default,
             app: :unified_example_numeric_input,
             directory: "examples/numeric_input",
             purpose: :widget_proof
           }
  end

  test "numeric_input example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = NumericInput.boot()
    assert {:ok, html} = NumericInput.render_html()

    assert runtime_state.assigns.iur.id == :numeric_input_example_screen_shell

    assert %UnifiedIUR.Element{kind: :numeric_input} =
             Tree.find_by_id(runtime_state.assigns.iur, :numeric_input_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Numeric Input Widget Example"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "type=\"number\""
    assert html =~ "data-live-ui-variant=\"filled\""
  end
end
