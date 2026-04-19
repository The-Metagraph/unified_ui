defmodule UnifiedExamples.AlertDialogTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.AlertDialog
  alias UnifiedExamples.AlertDialog.Screen

  @endpoint UnifiedExamples.AlertDialog.Endpoint

  test "alert dialog example exposes self-contained example metadata" do
    metadata = AlertDialog.metadata()

    assert metadata.id == :alert_dialog_example_screen
    assert metadata.root_id == :alert_dialog_example_screen_root
    assert metadata.title == "Alert Dialog Widget Example"
    assert metadata.summary == "Focused overlay example using the local example shell"
    assert metadata.notes == "Alert-dialog examples foreground one canonical destructive confirmation surface inside the local shell."
    assert metadata.widget == :alert_dialog
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_alert_dialog
    assert metadata.directory == "examples/alert_dialog"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.AlertDialog.Application,
             UnifiedExamples.AlertDialog.Endpoint,
             UnifiedExamples.AlertDialog.Router,
             UnifiedExamples.AlertDialog.Layouts,
             UnifiedExamples.AlertDialog.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.AlertDialog.Screen,
             UnifiedExamples.AlertDialog.Theme,
             UnifiedExamples.AlertDialog.StyleProfile,
             UnifiedExamples.AlertDialog.Helpers
           ]
    assert metadata.style_contract.component_style_ids == [
             :example_shell,
             :example_panel,
             :example_form_shell,
             :example_title,
             :example_summary,
             :example_notes,
             :example_primary_button,
             :example_primary_input
           ]
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :open
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "alert dialog example renders the local shell and foregrounds one primary alert dialog" do
    assert {:ok, runtime_state} = AlertDialog.boot()
    assert {:ok, html} = AlertDialog.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :alert_dialog_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"alert-dialog\""
    assert html =~ "Alert Dialog Widget Example"
    assert html =~ "Paging the on-call owner will create a responder page."
    assert html =~ "Inspect the alert dialog layered story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "alert dialog example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/alert_dialog\""
    assert body =~ "Alert Dialog Widget Example"
    assert body =~ "data-live-ui-widget=\"alert-dialog\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
