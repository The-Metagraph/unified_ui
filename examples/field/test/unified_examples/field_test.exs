defmodule UnifiedExamples.FieldTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Field

  test "field example exposes standalone example metadata" do
    assert Field.metadata() == %{
             id: :field_example_screen,
             root_id: :field_example_screen_root,
             title: "Field Example",
             summary: "Focused form-oriented example using the shared suite shell",
             notes:
               "Field examples keep the shared form shell while foregrounding one primary labeled field.",
             widget: :field,
             theme_id: :example_suite_default,
             app: :unified_example_field,
             directory: "examples/field",
             purpose: :widget_proof
           }
  end

  test "field example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Field.boot()
    assert {:ok, html} = Field.render_html()

    assert runtime_state.assigns.iur.id == :field_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Field Example"
    assert html =~ "data-live-ui-widget=\"field\""
    assert html =~ "Display name"
    assert html =~ "data-live-ui-widget=\"text-input\""
  end
end
