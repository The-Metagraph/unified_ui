defmodule UnifiedExamples.FieldGroupTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.FieldGroup

  test "field_group example exposes standalone example metadata" do
    assert FieldGroup.metadata() == %{
             id: :field_group_example_screen,
             root_id: :field_group_example_screen_root,
             title: "Field Group Example",
             summary: "Focused form-oriented example using the shared suite shell",
             notes:
               "Field group examples keep the shared form shell while foregrounding one grouped set of fields.",
             widget: :field_group,
             theme_id: :example_suite_default,
             app: :unified_example_field_group,
             directory: "examples/field_group",
             purpose: :widget_proof
           }
  end

  test "field_group example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = FieldGroup.boot()
    assert {:ok, html} = FieldGroup.render_html()

    assert runtime_state.assigns.iur.id == :field_group_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Field Group Example"
    assert html =~ "data-live-ui-widget=\"field-group\""
    assert html =~ "Notification preferences"
    assert html =~ "data-live-ui-widget=\"text-input\""
  end
end
