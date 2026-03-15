defmodule UnifiedExamples.CheckboxTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Checkbox

  test "checkbox example exposes standalone example metadata" do
    assert Checkbox.metadata() == %{
             id: :checkbox_example_screen,
             root_id: :checkbox_example_screen_root,
             title: "Checkbox Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Checkbox examples keep the shared form shell while foregrounding one boolean control.",
             widget: :checkbox,
             theme_id: :example_suite_default,
             app: :unified_example_checkbox,
             directory: "examples/checkbox",
             purpose: :widget_proof
           }
  end

  test "checkbox example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = Checkbox.boot()
    assert {:ok, html} = Checkbox.render_html()

    assert runtime_state.assigns.iur.id == :checkbox_example_screen_shell

    assert %UnifiedIUR.Element{kind: :checkbox} =
             Tree.find_by_id(runtime_state.assigns.iur, :checkbox_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Checkbox Widget Example"
    assert html =~ "data-live-ui-widget=\"toggle\""
    assert html =~ "type=\"checkbox\""
    assert html =~ "data-live-ui-variant=\"filled\""
  end
end
