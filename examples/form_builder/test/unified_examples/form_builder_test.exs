defmodule UnifiedExamples.FormBuilderTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.FormBuilder

  test "form_builder example exposes standalone example metadata" do
    metadata = FormBuilder.metadata()

    assert metadata.id == :form_builder_example_screen
    assert metadata.root_id == :form_builder_example_screen_root
    assert metadata.widget == :form_builder
    assert metadata.app == :unified_example_form_builder
    assert metadata.directory == "examples/form_builder"
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
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
    assert html =~ "phx-change=\"canonical_change_interaction\""
  end
end
