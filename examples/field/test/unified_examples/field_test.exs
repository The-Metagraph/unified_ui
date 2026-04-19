defmodule UnifiedExamples.FieldTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Field
  alias UnifiedExamples.Field.Screen

  @endpoint UnifiedExamples.Field.Endpoint

  test "field example exposes self-contained example metadata" do
    metadata = Field.metadata()

    assert metadata.id == :field_example_screen
    assert metadata.root_id == :field_example_screen_root
    assert metadata.title == "Field Example"
    assert metadata.summary == "Focused form-oriented example using the local example shell"
    assert metadata.notes == "Field examples keep the local form shell while foregrounding one primary labeled field."
    assert metadata.widget == :field
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_field
    assert metadata.directory == "examples/field"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Field.Application,
             UnifiedExamples.Field.Endpoint,
             UnifiedExamples.Field.Router,
             UnifiedExamples.Field.Layouts,
             UnifiedExamples.Field.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Field.Screen,
             UnifiedExamples.Field.Theme,
             UnifiedExamples.Field.StyleProfile,
             UnifiedExamples.Field.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "field example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = Field.boot()
    assert {:ok, html} = Field.render_html()

    assert runtime_state.assigns.iur.id == :field_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Field Example"
    assert html =~ "data-live-ui-widget=\"field\""
    assert html =~ "Display name"
    assert html =~ "data-live-ui-widget=\"text-input\""
    assert html =~ "phx-change=\"canonical_change_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "field example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/field\""
    assert body =~ "Field Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
