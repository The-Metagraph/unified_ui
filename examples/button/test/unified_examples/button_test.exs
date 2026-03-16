defmodule UnifiedExamples.ButtonTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Button
  alias UnifiedExamples.Shared.Tooling

  test "button example exposes standalone example metadata" do
    metadata = Button.metadata()

    assert metadata.id == :button_example_screen
    assert metadata.root_id == :button_example_screen_root
    assert metadata.title == "Button Widget Example"
    assert metadata.widget == :button
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_button
    assert metadata.directory == "examples/button"
    assert metadata.purpose == :widget_proof
    assert metadata.interaction_demo.mode == :custom
    assert metadata.interaction_demo.family == :click
    assert metadata.interaction_demo.source == :primary_widget
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
    assert html =~ "phx-click=\"canonical_interaction\""
    assert html =~ "Canonical Signal Preview"
  end

  test "button example boots through its Phoenix LiveView app entrypoint" do
    assert {:ok, smoke} = Tooling.smoke_launch("button")

    assert smoke.status == 200
    assert smoke.body =~ "data-example-directory=\"examples/button\""
    assert smoke.body =~ "Button Widget Example"
    assert smoke.body =~ "data-live-ui-widget=\"button\""
  end
end
