defmodule UnifiedExamples.IconTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Icon
  alias UnifiedExamples.Icon.Screen

  @endpoint UnifiedExamples.Icon.Endpoint

  test "icon example exposes self-contained example metadata" do
    metadata = Icon.metadata()

    assert metadata.id == :icon_example_screen
    assert metadata.root_id == :icon_example_screen_root
    assert metadata.title == "Icon Widget Example"
    assert metadata.summary == "Focused content-oriented example using the local example shell"
    assert metadata.notes == "Icon examples keep the local shell while foregrounding one primary icon widget."
    assert metadata.widget == :icon
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_icon
    assert metadata.directory == "examples/icon"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Icon.Application,
             UnifiedExamples.Icon.Endpoint,
             UnifiedExamples.Icon.Router,
             UnifiedExamples.Icon.Layouts,
             UnifiedExamples.Icon.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Icon.Screen,
             UnifiedExamples.Icon.Theme,
             UnifiedExamples.Icon.StyleProfile,
             UnifiedExamples.Icon.Helpers
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

  test "icon example renders the local shell and the focused widget" do
    assert {:ok, runtime_state} = Icon.boot()
    assert {:ok, html} = Icon.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :icon_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Icon Widget Example"
    assert html =~ "data-live-ui-widget=\"icon\""
    assert html =~ "Highlight the icon story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "icon example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/icon\""
    assert body =~ "Icon Widget Example"
    assert body =~ "data-live-ui-widget=\"icon\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
