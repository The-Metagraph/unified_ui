defmodule UnifiedExamples.ToastTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Toast
  alias UnifiedExamples.Toast.Screen

  @endpoint UnifiedExamples.Toast.Endpoint

  test "toast example exposes self-contained example metadata" do
    metadata = Toast.metadata()

    assert metadata.id == :toast_example_screen
    assert metadata.root_id == :toast_example_screen_root
    assert metadata.title == "Toast Widget Example"
    assert metadata.summary == "Focused overlay example using the local example shell"
    assert metadata.notes == "Toast examples foreground one canonical transient notification surface inside the local shell."
    assert metadata.widget == :toast
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_toast
    assert metadata.directory == "examples/toast"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Toast.Application,
             UnifiedExamples.Toast.Endpoint,
             UnifiedExamples.Toast.Router,
             UnifiedExamples.Toast.Layouts,
             UnifiedExamples.Toast.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Toast.Screen,
             UnifiedExamples.Toast.Theme,
             UnifiedExamples.Toast.StyleProfile,
             UnifiedExamples.Toast.Helpers
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

  test "toast example renders the local shell and foregrounds one primary toast" do
    assert {:ok, runtime_state} = Toast.boot()
    assert {:ok, html} = Toast.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :toast_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"toast\""
    assert html =~ "Toast Widget Example"
    assert html =~ "Runbook synced"
    assert html =~ "Inspect the toast layered story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "toast example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/toast\""
    assert body =~ "Toast Widget Example"
    assert body =~ "data-live-ui-widget=\"toast\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
