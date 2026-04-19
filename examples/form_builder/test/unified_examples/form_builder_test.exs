defmodule UnifiedExamples.FormBuilderTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.FormBuilder
  alias UnifiedExamples.FormBuilder.Screen

  @endpoint UnifiedExamples.FormBuilder.Endpoint

  test "form_builder example exposes self-contained example metadata" do
    metadata = FormBuilder.metadata()

    assert metadata.id == :form_builder_example_screen
    assert metadata.root_id == :form_builder_example_screen_root
    assert metadata.title == "Form Builder Example"
    assert metadata.summary == "Focused form-oriented example using the local example shell"
    assert metadata.notes == "Form builder examples keep the local form shell while foregrounding one primary form workflow."
    assert metadata.widget == :form_builder
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_form_builder
    assert metadata.directory == "examples/form_builder"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.FormBuilder.Application,
             UnifiedExamples.FormBuilder.Endpoint,
             UnifiedExamples.FormBuilder.Router,
             UnifiedExamples.FormBuilder.Layouts,
             UnifiedExamples.FormBuilder.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.FormBuilder.Screen,
             UnifiedExamples.FormBuilder.Theme,
             UnifiedExamples.FormBuilder.StyleProfile,
             UnifiedExamples.FormBuilder.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "form_builder example renders the local form shell and the focused widget" do
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
    assert html =~ "Meaningful Interaction Story"
  end

  test "form_builder example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/form_builder\""
    assert body =~ "Form Builder Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
