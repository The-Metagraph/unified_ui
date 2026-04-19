defmodule UnifiedExamples.ToggleTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Toggle
  alias UnifiedExamples.Toggle.Screen

  @endpoint UnifiedExamples.Toggle.Endpoint

  test "toggle example exposes self-contained example metadata" do
    metadata = Toggle.metadata()

    assert metadata.id == :toggle_example_screen
    assert metadata.root_id == :toggle_example_screen_root
    assert metadata.title == "Toggle Widget Example"
    assert metadata.summary == "Focused input-oriented example using the local example shell"
    assert metadata.notes == "Toggle examples keep the local form shell while foregrounding one boolean switch control."
    assert metadata.widget == :toggle
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_toggle
    assert metadata.directory == "examples/toggle"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Toggle.Application,
             UnifiedExamples.Toggle.Endpoint,
             UnifiedExamples.Toggle.Router,
             UnifiedExamples.Toggle.Layouts,
             UnifiedExamples.Toggle.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Toggle.Screen,
             UnifiedExamples.Toggle.Theme,
             UnifiedExamples.Toggle.StyleProfile,
             UnifiedExamples.Toggle.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :change
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "toggle example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = Toggle.boot()
    assert {:ok, html} = Toggle.render_html()

    assert runtime_state.assigns.iur.id == :toggle_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Toggle Widget Example"
    assert html =~ "data-live-ui-widget=\"toggle\""
    assert html =~ "type=\"checkbox\""
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_change_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "toggle example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/toggle\""
    assert body =~ "Toggle Widget Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
