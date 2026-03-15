defmodule UnifiedExamples.LogViewerTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.LogViewer

  test "log viewer example exposes standalone example metadata" do
    assert LogViewer.metadata() == %{
             id: :log_viewer_example_screen,
             root_id: :log_viewer_example_screen_root,
             title: "Log Viewer Widget Example",
             summary: "Focused data-oriented example using the shared suite shell",
             notes:
               "Log viewer examples foreground one canonical event stream inside the shared shell.",
             widget: :log_viewer,
             theme_id: :example_suite_default,
             app: :unified_example_log_viewer,
             directory: "examples/log_viewer",
             purpose: :widget_proof
           }
  end

  test "log viewer example renders the shared shell and foregrounds one primary log stream" do
    assert {:ok, runtime_state} = LogViewer.boot()
    assert {:ok, html} = LogViewer.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :log_viewer_example_screen_shell

    assert %UnifiedIUR.Element{kind: :log_viewer} =
             Tree.find_by_id(runtime_state.assigns.iur, :log_viewer_example_primary_logs)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"log-viewer\""
    assert html =~ "Log Viewer Widget Example"
    assert html =~ "Deploy started"
    assert html =~ "Queue lag detected"
    assert html =~ "2026-03-15T14:00:00Z"
  end
end
