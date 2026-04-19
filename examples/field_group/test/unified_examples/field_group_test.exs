defmodule UnifiedExamples.FieldGroupTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.FieldGroup
  alias UnifiedExamples.FieldGroup.Screen

  @endpoint UnifiedExamples.FieldGroup.Endpoint

  test "field_group example exposes self-contained example metadata" do
    metadata = FieldGroup.metadata()

    assert metadata.id == :field_group_example_screen
    assert metadata.root_id == :field_group_example_screen_root
    assert metadata.title == "Field Group Example"
    assert metadata.summary == "Focused form-oriented example using the local example shell"
    assert metadata.notes == "Field group examples keep the local form shell while foregrounding one grouped set of fields."
    assert metadata.widget == :field_group
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_field_group
    assert metadata.directory == "examples/field_group"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.FieldGroup.Application,
             UnifiedExamples.FieldGroup.Endpoint,
             UnifiedExamples.FieldGroup.Router,
             UnifiedExamples.FieldGroup.Layouts,
             UnifiedExamples.FieldGroup.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.FieldGroup.Screen,
             UnifiedExamples.FieldGroup.Theme,
             UnifiedExamples.FieldGroup.StyleProfile,
             UnifiedExamples.FieldGroup.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "field_group example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = FieldGroup.boot()
    assert {:ok, html} = FieldGroup.render_html()

    assert runtime_state.assigns.iur.id == :field_group_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Field Group Example"
    assert html =~ "data-live-ui-widget=\"field-group\""
    assert html =~ "Notification preferences"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "phx-change=\"canonical_change_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "field_group example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/field_group\""
    assert body =~ "Field Group Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
