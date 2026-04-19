defmodule UnifiedExamples.BoxTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Box
  alias UnifiedExamples.Box.Screen

  @endpoint UnifiedExamples.Box.Endpoint

  test "box example exposes self-contained example metadata" do
    metadata = Box.metadata()

    assert metadata.id == :box_example_screen
    assert metadata.root_id == :box_example_screen_root
    assert metadata.title == "Box Widget Example"
    assert metadata.summary == "Focused layout-oriented example using the local example shell"
    assert metadata.notes == "Box examples keep the local shell while foregrounding one primary layout container."
    assert metadata.widget == :box
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_box
    assert metadata.directory == "examples/box"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Box.Application,
             UnifiedExamples.Box.Endpoint,
             UnifiedExamples.Box.Router,
             UnifiedExamples.Box.Layouts,
             UnifiedExamples.Box.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Box.Screen,
             UnifiedExamples.Box.Theme,
             UnifiedExamples.Box.StyleProfile,
             UnifiedExamples.Box.Helpers
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
    assert metadata.interaction_demo.family == :click
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "box example renders the local shell and the focused widget" do
    assert {:ok, runtime_state} = Box.boot()
    assert {:ok, html} = Box.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :box_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Box Widget Example"
    assert html =~ "Self-contained box container"
    assert html =~ "Review the box layout story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "box example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/box\""
    assert body =~ "Box Widget Example"
    assert body =~ "data-live-ui-widget=\"box\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
