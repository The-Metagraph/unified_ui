defmodule UnifiedExamples.DialogTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Dialog
  alias UnifiedExamples.Dialog.Screen

  @endpoint UnifiedExamples.Dialog.Endpoint

  test "dialog example exposes self-contained example metadata" do
    metadata = Dialog.metadata()

    assert metadata.id == :dialog_example_screen
    assert metadata.root_id == :dialog_example_screen_root
    assert metadata.title == "Dialog Widget Example"
    assert metadata.summary == "Focused overlay example using the local example shell"
    assert metadata.notes == "Dialog examples foreground one canonical modal surface inside the local shell."
    assert metadata.widget == :dialog
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_dialog
    assert metadata.directory == "examples/dialog"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Dialog.Application,
             UnifiedExamples.Dialog.Endpoint,
             UnifiedExamples.Dialog.Router,
             UnifiedExamples.Dialog.Layouts,
             UnifiedExamples.Dialog.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Dialog.Screen,
             UnifiedExamples.Dialog.Theme,
             UnifiedExamples.Dialog.StyleProfile,
             UnifiedExamples.Dialog.Helpers
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

  test "dialog example renders the local shell and foregrounds one primary dialog" do
    assert {:ok, runtime_state} = Dialog.boot()
    assert {:ok, html} = Dialog.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :dialog_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"dialog\""
    assert html =~ "Dialog Widget Example"
    assert html =~ "Review escalation windows and routing defaults"
    assert html =~ "Inspect the dialog layered story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "dialog example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/dialog\""
    assert body =~ "Dialog Widget Example"
    assert body =~ "data-live-ui-widget=\"dialog\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
