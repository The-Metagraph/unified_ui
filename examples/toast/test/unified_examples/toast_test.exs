defmodule UnifiedExamples.ToastTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Toast

  test "toast example exposes standalone example metadata" do
    assert Toast.metadata() == %{
             id: :toast_example_screen,
             root_id: :toast_example_screen_root,
             title: "Toast Widget Example",
             summary: "Focused overlay example using the shared suite shell",
             notes:
               "Toast examples foreground one canonical transient notification surface inside the shared shell.",
             widget: :toast,
             theme_id: :example_suite_default,
             app: :unified_example_toast,
             directory: "examples/toast",
             purpose: :widget_proof
           }
  end

  test "toast example renders the shared shell and foregrounds one primary toast" do
    assert {:ok, runtime_state} = Toast.boot()
    assert {:ok, html} = Toast.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :toast_example_screen_shell

    assert %UnifiedIUR.Element{kind: :toast} =
             Tree.find_by_id(runtime_state.assigns.iur, :toast_example_primary_toast)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"toast\""
    assert html =~ "Toast Widget Example"
    assert html =~ "Runbook synced"
  end
end
