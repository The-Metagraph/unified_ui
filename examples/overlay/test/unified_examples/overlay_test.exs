defmodule UnifiedExamples.OverlayTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Overlay
  alias UnifiedExamples.Overlay.Screen

  @endpoint UnifiedExamples.Overlay.Endpoint

  test "overlay example exposes self-contained example metadata" do
    metadata = Overlay.metadata()

    assert metadata.id == :overlay_example_screen
    assert metadata.root_id == :overlay_example_screen_root
    assert metadata.title == "Overlay Widget Example"
    assert metadata.summary == "Focused overlay example using the local example shell"
    assert metadata.notes == "Overlay examples foreground one canonical layered surface inside the local shell."
    assert metadata.widget == :overlay
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_overlay
    assert metadata.directory == "examples/overlay"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Overlay.Application,
             UnifiedExamples.Overlay.Endpoint,
             UnifiedExamples.Overlay.Router,
             UnifiedExamples.Overlay.Layouts,
             UnifiedExamples.Overlay.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Overlay.Screen,
             UnifiedExamples.Overlay.Theme,
             UnifiedExamples.Overlay.StyleProfile,
             UnifiedExamples.Overlay.Helpers
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
    assert metadata.interaction_demo.family == :open
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "overlay example renders the local shell and foregrounds one primary overlay surface" do
    assert {:ok, runtime_state} = Overlay.boot()
    assert {:ok, html} = Overlay.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :overlay_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"overlay-surface\""
    assert html =~ "Overlay Widget Example"
    assert html =~ "Coordinator workspace"
    assert html =~ "Runbook synced"
    assert html =~ "Inspect the overlay layered story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "overlay example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/overlay\""
    assert body =~ "Overlay Widget Example"
    assert body =~ "data-live-ui-widget=\"overlay-surface\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
