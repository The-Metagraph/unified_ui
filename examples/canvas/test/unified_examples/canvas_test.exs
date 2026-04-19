defmodule UnifiedExamples.CanvasTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Canvas
  alias UnifiedExamples.Canvas.Screen

  @endpoint UnifiedExamples.Canvas.Endpoint

  test "canvas example exposes self-contained example metadata" do
    metadata = Canvas.metadata()

    assert metadata.id == :canvas_example_screen
    assert metadata.root_id == :canvas_example_screen_root
    assert metadata.title == "Canvas Widget Example"
    assert metadata.summary == "Focused display-system example using the local example shell"
    assert metadata.notes == "Canvas examples foreground one canonical drawing surface inside the local shell."
    assert metadata.widget == :canvas
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_canvas
    assert metadata.directory == "examples/canvas"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Canvas.Application,
             UnifiedExamples.Canvas.Endpoint,
             UnifiedExamples.Canvas.Router,
             UnifiedExamples.Canvas.Layouts,
             UnifiedExamples.Canvas.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Canvas.Screen,
             UnifiedExamples.Canvas.Theme,
             UnifiedExamples.Canvas.StyleProfile,
             UnifiedExamples.Canvas.Helpers
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

  test "canvas example renders the local shell and foregrounds one primary canvas" do
    assert {:ok, runtime_state} = Canvas.boot()
    assert {:ok, html} = Canvas.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :canvas_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"canvas\""
    assert html =~ "Canvas Widget Example"
    assert html =~ "Alert"
    assert html =~ "Inspect the canvas display story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "canvas example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/canvas\""
    assert body =~ "Canvas Widget Example"
    assert body =~ "data-live-ui-widget=\"canvas\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
