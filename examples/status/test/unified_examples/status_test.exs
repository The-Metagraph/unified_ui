defmodule UnifiedExamples.StatusTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Status

  test "status example exposes standalone example metadata" do
    assert Status.metadata() == %{
             id: :status_example_screen,
             root_id: :status_example_screen_root,
             title: "Status Widget Example",
             summary: "Focused feedback-oriented example using the shared suite shell",
             notes:
               "Status examples foreground one canonical status line inside the shared shell.",
             widget: :status,
             theme_id: :example_suite_default,
             app: :unified_example_status,
             directory: "examples/status",
             purpose: :widget_proof
           }
  end

  test "status example renders the shared shell and foregrounds one primary status line" do
    assert {:ok, runtime_state} = Status.boot()
    assert {:ok, html} = Status.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :status_example_screen_shell

    assert %UnifiedIUR.Element{kind: :status} =
             Tree.find_by_id(runtime_state.assigns.iur, :status_example_primary_status)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"status\""
    assert html =~ "Status Widget Example"
    assert html =~ "Release train stable"
  end
end
