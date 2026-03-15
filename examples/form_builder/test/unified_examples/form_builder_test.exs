defmodule UnifiedExamples.FormBuilderTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.FormBuilder

  test "form_builder example exposes standalone example metadata" do
    assert FormBuilder.metadata() == %{
             id: :form_builder_example_screen,
             root_id: :form_builder_example_screen_root,
             title: "Form Builder Example",
             summary: "Focused form-oriented example using the shared suite shell",
             notes:
               "Form builder examples keep the shared form shell while foregrounding one primary form workflow.",
             widget: :form_builder,
             theme_id: :example_suite_default,
             app: :unified_example_form_builder,
             directory: "examples/form_builder",
             purpose: :widget_proof
           }
  end

  test "form_builder example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = FormBuilder.boot()
    assert {:ok, html} = FormBuilder.render_html()

    assert runtime_state.assigns.iur.id == :form_builder_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Form Builder Example"
    assert html =~ "data-live-ui-widget=\"field-group\""
    assert html =~ "data-live-ui-widget=\"field\""
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "Save profile"
  end
end
