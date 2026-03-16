defmodule UnifiedExamples.ButtonTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias UnifiedExamples.Button
  alias UnifiedExamples.Shared.Tooling

  @endpoint UnifiedExamples.Button.Endpoint

  test "button example exposes standalone example metadata" do
    assert Button.metadata() == %{
             id: :button_example_screen,
             root_id: :button_example_screen_root,
             title: "Button Widget Example",
             summary: "Focused action-oriented example using the shared suite shell",
             notes:
               "Click the button to inspect the canonical signal compiled from the authored DSL.",
             widget: :button,
             theme_id: :example_suite_default,
             app: :unified_example_button,
             directory: "examples/button",
             purpose: :widget_proof
           }
  end

  test "button example renders the shared shell and the focused action widget" do
    assert {:ok, runtime_state} = Button.boot()
    assert {:ok, html} = Button.render_html()

    assert runtime_state.assigns.iur.id == :button_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Button Widget Example"
    assert html =~ "data-live-ui-widget=\"button\""
    assert html =~ "Save profile"
    assert html =~ "data-live-ui-variant=\"solid\""
    assert html =~ "data-live-ui-signal-preview=\"true\""
    assert html =~ "No signal captured yet"
  end

  test "button example boots through its Phoenix LiveView app entrypoint" do
    assert {:ok, smoke} = Tooling.smoke_launch("button")

    assert smoke.status == 200
    assert smoke.body =~ "data-example-directory=\"examples/button\""
    assert smoke.body =~ "Button Widget Example"
    assert smoke.body =~ "jido_run inspired live_ui example"
    assert smoke.body =~ "data-live-ui-widget=\"button\""
    assert smoke.body =~ "<meta name=\"csrf-token\""
    assert smoke.body =~ "/vendor/phoenix/phoenix.js"
    assert smoke.body =~ "/vendor/live_view/phoenix_live_view.js"
  end

  test "button example clicks surface the canonical signal preview through LiveView" do
    {:ok, view, html} = live(build_conn(), "/")

    assert html =~ "Save profile"
    assert html =~ "data-live-ui-signal-preview=\"true\""
    assert html =~ "No signal captured yet"

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
