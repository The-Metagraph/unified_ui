defmodule UnifiedExamples.CheckboxTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Checkbox
  alias UnifiedExamples.Checkbox.Screen

  @endpoint UnifiedExamples.Checkbox.Endpoint

  test "checkbox example exposes self-contained example metadata" do
    metadata = Checkbox.metadata()

    assert metadata.id == :checkbox_example_screen
    assert metadata.root_id == :checkbox_example_screen_root
    assert metadata.title == "Checkbox Widget Example"
    assert metadata.summary == "Focused input-oriented example using the local example shell"
    assert metadata.notes == "Checkbox examples keep the local form shell while foregrounding one boolean control."
    assert metadata.widget == :checkbox
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_checkbox
    assert metadata.directory == "examples/checkbox"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Checkbox.Application,
             UnifiedExamples.Checkbox.Endpoint,
             UnifiedExamples.Checkbox.Router,
             UnifiedExamples.Checkbox.Layouts,
             UnifiedExamples.Checkbox.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Checkbox.Screen,
             UnifiedExamples.Checkbox.Theme,
             UnifiedExamples.Checkbox.StyleProfile,
             UnifiedExamples.Checkbox.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "checkbox example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = Checkbox.boot()
    assert {:ok, html} = Checkbox.render_html()

    assert runtime_state.assigns.iur.id == :checkbox_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Checkbox Widget Example"
    assert html =~ "data-live-ui-widget=\"toggle\""
    assert html =~ "type=\"checkbox\""
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_change_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "checkbox example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/checkbox\""
    assert body =~ "Checkbox Widget Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
