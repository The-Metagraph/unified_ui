defmodule UnifiedExamples.StatusTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Status

  test "status example exposes standalone example metadata" do
    metadata = Status.metadata()

    assert metadata.id == :status_example_screen
    assert metadata.root_id == :status_example_screen_root
    assert metadata.widget == :status
    assert metadata.app == :unified_example_status
    assert metadata.directory == "examples/status"
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :click
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
    assert html =~ "Inspect the status feedback story"
    assert html =~ "Meaningful Interaction Story"
  end
end
