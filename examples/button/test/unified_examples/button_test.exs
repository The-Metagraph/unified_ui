defmodule UnifiedExamples.ButtonTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.Button
  alias UnifiedExamples.Button.Screen

  @endpoint UnifiedExamples.Button.Endpoint

  test "button example exposes self-contained example metadata" do
    metadata = Button.metadata()

    assert metadata.id == :button_example_screen
    assert metadata.root_id == :button_example_screen_root
    assert metadata.title == "Button Widget Example"
    assert metadata.summary == "Focused action-oriented example using the local example shell"

    assert metadata.notes ==
             "Click the button to inspect the canonical signal compiled from the self-contained authored DSL."

    assert metadata.widget == :button
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_button
    assert metadata.directory == "examples/button"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Button.Application,
             UnifiedExamples.Button.Endpoint,
             UnifiedExamples.Button.Router,
             UnifiedExamples.Button.Layouts,
             UnifiedExamples.Button.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Button.Screen,
             UnifiedExamples.Button.Theme,
             UnifiedExamples.Button.StyleProfile,
             UnifiedExamples.Button.Helpers
           ]
    assert metadata.interaction_demo.mode == :custom
    assert metadata.interaction_demo.family == :click
    assert metadata.interaction_demo.source == :primary_widget
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "button example renders the local shell and the focused action widget" do
    assert {:ok, runtime_state} = Button.boot()
    assert {:ok, html} = Button.render_html()

    assert runtime_state.assigns.iur.id == :button_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Button Widget Example"
    assert html =~ "data-live-ui-widget=\"button\""
    assert html =~ "Save profile"
    assert html =~ "data-live-ui-variant=\"solid\""
    assert html =~ "data-live-ui-signal-preview=\"true\""
    assert html =~ "Meaningful Interaction Story"
    assert html =~ "Canonical Signal Preview"
    assert html =~ "phx-click=\"canonical_interaction\""
  end

  test "button example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/button\""
    assert body =~ "Button Widget Example"
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "data-live-ui-widget=\"button\""
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end

  test "button example clicks surface the canonical signal preview through LiveView" do
    {:ok, view, html} = live(build_conn(), "/")

    assert html =~ "Save profile"
    assert html =~ "data-live-ui-signal-preview=\"true\""
    assert html =~ "Click Save profile to emit the authored canonical button signal."

    updated_html =
      view
      |> element("#button_example_primary_action")
      |> render_click()

    assert updated_html =~ "data-live-ui-signal-preview=\"true\""
    assert updated_html =~ "live_ui.click.save_profile"
    assert updated_html =~ "action: :save_profile"
    assert updated_html =~ "example: :button"
    assert updated_html =~ "click:save_profile"
  end
end
