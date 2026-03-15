defmodule UnifiedExamples.DateInputTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.DateInput

  test "date_input example exposes standalone example metadata" do
    assert DateInput.metadata() == %{
             id: :date_input_example_screen,
             root_id: :date_input_example_screen_root,
             title: "Date Input Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Date input examples keep the shared form shell while foregrounding one date control.",
             widget: :date_input,
             theme_id: :example_suite_default,
             app: :unified_example_date_input,
             directory: "examples/date_input",
             purpose: :widget_proof
           }
  end

  test "date_input example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = DateInput.boot()
    assert {:ok, html} = DateInput.render_html()

    assert runtime_state.assigns.iur.id == :date_input_example_screen_shell

    assert %UnifiedIUR.Element{kind: :date_input} =
             Tree.find_by_id(runtime_state.assigns.iur, :date_input_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Date Input Widget Example"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "type=\"date\""
    assert html =~ "data-live-ui-variant=\"filled\""
  end
end
