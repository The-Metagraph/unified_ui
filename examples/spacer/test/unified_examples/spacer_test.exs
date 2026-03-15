defmodule UnifiedExamples.SpacerTest do
  use ExUnit.Case, async: true

  alias UnifiedExamples.Spacer

  test "spacer example exposes standalone example metadata" do
    assert Spacer.metadata() == %{
             id: :spacer_example_screen,
             root_id: :spacer_example_screen_root,
             title: "Spacer Widget Example",
             summary: "Focused content-oriented example using the shared suite shell",
             notes:
               "Spacer examples keep the shared shell while foregrounding one primary spacer widget.",
             widget: :spacer,
             theme_id: :example_suite_default,
             app: :unified_example_spacer,
             directory: "examples/spacer",
             purpose: :widget_proof
           }
  end

  test "spacer example renders the shared shell and the focused content widget" do
    assert {:ok, runtime_state} = Spacer.boot()
    assert {:ok, html} = Spacer.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :spacer_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Spacer Widget Example"
    assert html =~ "data-live-ui-widget=\"spacer\""
  end
end
