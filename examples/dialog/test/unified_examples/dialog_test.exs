defmodule UnifiedExamples.DialogTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.Dialog

  test "dialog example exposes standalone example metadata" do
    assert Dialog.metadata() == %{
             id: :dialog_example_screen,
             root_id: :dialog_example_screen_root,
             title: "Dialog Widget Example",
             summary: "Focused overlay example using the shared suite shell",
             notes:
               "Dialog examples foreground one canonical modal surface inside the shared shell.",
             widget: :dialog,
             theme_id: :example_suite_default,
             app: :unified_example_dialog,
             directory: "examples/dialog",
             purpose: :widget_proof
           }
  end

  test "dialog example renders the shared shell and foregrounds one primary dialog" do
    assert {:ok, runtime_state} = Dialog.boot()
    assert {:ok, html} = Dialog.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :dialog_example_screen_shell

    assert %UnifiedIUR.Element{kind: :dialog} =
             Tree.find_by_id(runtime_state.assigns.iur, :dialog_example_primary_dialog)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"dialog\""
    assert html =~ "data-live-ui-dialog-slot=\"content\""
    assert html =~ "Dialog Widget Example"
    assert html =~ "Review escalation windows and routing defaults"
  end
end
