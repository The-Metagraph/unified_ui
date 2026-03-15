defmodule UnifiedExamples.AlertDialogTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.AlertDialog

  test "alert dialog example exposes standalone example metadata" do
    assert AlertDialog.metadata() == %{
             id: :alert_dialog_example_screen,
             root_id: :alert_dialog_example_screen_root,
             title: "Alert Dialog Widget Example",
             summary: "Focused overlay example using the shared suite shell",
             notes:
               "Alert-dialog examples foreground one canonical destructive confirmation surface inside the shared shell.",
             widget: :alert_dialog,
             theme_id: :example_suite_default,
             app: :unified_example_alert_dialog,
             directory: "examples/alert_dialog",
             purpose: :widget_proof
           }
  end

  test "alert dialog example renders the shared shell and foregrounds one primary alert dialog" do
    assert {:ok, runtime_state} = AlertDialog.boot()
    assert {:ok, html} = AlertDialog.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :alert_dialog_example_screen_shell

    assert %UnifiedIUR.Element{kind: :alert_dialog} =
             Tree.find_by_id(
               runtime_state.assigns.iur,
               :alert_dialog_example_primary_alert_dialog
             )

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"alert-dialog\""
    assert html =~ "data-live-ui-alert-slot=\"content\""
    assert html =~ "Alert Dialog Widget Example"
    assert html =~ "Paging the on-call owner will create a responder page."
  end
end
