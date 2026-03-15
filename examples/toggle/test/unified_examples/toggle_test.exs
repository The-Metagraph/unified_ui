defmodule UnifiedExamples.ToggleTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Toggle

  test "toggle example exposes standalone example metadata" do
    assert Toggle.metadata() == %{
             id: :toggle_example_screen,
             root_id: :toggle_example_screen_root,
             title: "Toggle Widget Example",
             summary: "Focused input-oriented example using the shared suite shell",
             notes:
               "Toggle examples keep the shared form shell while foregrounding one boolean switch control.",
             widget: :toggle,
             theme_id: :example_suite_default,
             app: :unified_example_toggle,
             directory: "examples/toggle",
             purpose: :widget_proof
           }
  end

  test "toggle example renders the shared shell and the focused input widget" do
    assert {:ok, runtime_state} = Toggle.boot()
    assert {:ok, html} = Toggle.render_html()

    assert runtime_state.assigns.iur.id == :toggle_example_screen_shell

    assert %UnifiedIUR.Element{kind: :toggle} =
             Tree.find_by_id(runtime_state.assigns.iur, :toggle_example_primary_input)

    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Toggle Widget Example"
    assert html =~ "data-live-ui-widget=\"toggle\""
    assert html =~ "type=\"checkbox\""
    assert html =~ "data-live-ui-variant=\"filled\""
  end
end
