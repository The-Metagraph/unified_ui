defmodule UnifiedExamples.ButtonTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Button
  alias UnifiedExamples.Shared.Tooling

  test "button example exposes standalone example metadata" do
    assert Button.metadata() == %{
             id: :button_example_screen,
             root_id: :button_example_screen_root,
             title: "Button Widget Example",
             summary: "Focused action-oriented example using the shared suite shell",
             notes: "Buttons keep the shared shell while foregrounding one primary action.",
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
    assert html =~ "data-live-ui-variant=\"quiet\""
  end

  test "button example boots through its Phoenix LiveView app entrypoint" do
    assert {:ok, smoke} = Tooling.smoke_launch("button")

    assert smoke.status == 200
    assert smoke.body =~ "data-example-directory=\"examples/button\""
    assert smoke.body =~ "Button Widget Example"
    assert smoke.body =~ "data-live-ui-widget=\"button\""
  end
end
