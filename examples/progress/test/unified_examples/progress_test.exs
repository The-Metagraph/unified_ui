defmodule UnifiedExamples.ProgressTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Progress

  test "progress example exposes standalone example metadata" do
    assert Progress.metadata() == %{
             id: :progress_example_screen,
             root_id: :progress_example_screen_root,
             title: "Progress Widget Example",
             summary: "Focused feedback-oriented example using the shared suite shell",
             notes:
               "Progress examples foreground one canonical progress indicator inside the shared shell.",
             widget: :progress,
             theme_id: :example_suite_default,
             app: :unified_example_progress,
             directory: "examples/progress",
             purpose: :widget_proof
           }
  end

  test "progress example renders the shared shell and foregrounds one primary progress indicator" do
    assert {:ok, runtime_state} = Progress.boot()
    assert {:ok, html} = Progress.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :progress_example_screen_shell

    assert %UnifiedIUR.Element{kind: :progress} =
             Tree.find_by_id(runtime_state.assigns.iur, :progress_example_primary_progress)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"progress\""
    assert html =~ "Progress Widget Example"
    assert html =~ "Deploy progress"
  end
end
