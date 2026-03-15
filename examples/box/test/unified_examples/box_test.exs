defmodule UnifiedExamples.BoxTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Box

  test "box example exposes standalone example metadata" do
    assert Box.metadata() == %{
             id: :box_example_screen,
             root_id: :box_example_screen_root,
             title: "Box Widget Example",
             summary: "Focused layout-oriented example using the shared suite shell",
             notes:
               "Box examples keep the shared shell while foregrounding the shared panel box as the primary layout container.",
             widget: :box,
             theme_id: :example_suite_default,
             app: :unified_example_box,
             directory: "examples/box",
             purpose: :widget_proof
           }
  end

  test "box example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Box.boot()
    assert {:ok, html} = Box.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :box_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Box Widget Example"
    assert html =~ "Shared box container"
    assert html =~ "Box widgets gather related content inside a shared visual boundary."
    assert html =~ "data-live-ui-variant=\"panel\""
  end
end
