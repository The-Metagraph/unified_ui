defmodule UnifiedExamples.ViewportTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Viewport
  alias UnifiedExamples.Viewport.Screen

  @endpoint UnifiedExamples.Viewport.Endpoint

  test "viewport example exposes self-contained example metadata" do
    metadata = Viewport.metadata()

    assert metadata.id == :viewport_example_screen
    assert metadata.root_id == :viewport_example_screen_root
    assert metadata.title == "Viewport Widget Example"
    assert metadata.summary == "Focused display-system example using the local example shell"
    assert metadata.notes == "Viewport examples foreground one canonical clipped region inside the local shell."
    assert metadata.widget == :viewport
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_viewport
    assert metadata.directory == "examples/viewport"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Viewport.Application,
             UnifiedExamples.Viewport.Endpoint,
             UnifiedExamples.Viewport.Router,
             UnifiedExamples.Viewport.Layouts,
             UnifiedExamples.Viewport.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Viewport.Screen,
             UnifiedExamples.Viewport.Theme,
             UnifiedExamples.Viewport.StyleProfile,
             UnifiedExamples.Viewport.Helpers
           ]
    assert metadata.style_contract.component_style_ids == [
             :example_shell,
             :example_panel,
             :example_form_shell,
             :example_title,
             :example_summary,
             :example_notes,
             :example_primary_button,
             :example_primary_input
           ]
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :focus
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "viewport example renders the local shell and foregrounds one primary viewport" do
    assert {:ok, runtime_state} = Viewport.boot()
    assert {:ok, html} = Viewport.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :viewport_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"viewport\""
    assert html =~ "Viewport Widget Example"
    assert html =~ "Incident timeline"
    assert html =~ "Incident INC-101 escalated to the response lead"
    assert html =~ "Inspect the viewport display story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "viewport example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/viewport\""
    assert body =~ "Viewport Widget Example"
    assert body =~ "data-live-ui-widget=\"viewport\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
