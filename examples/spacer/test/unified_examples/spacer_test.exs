defmodule UnifiedExamples.SpacerTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Spacer
  alias UnifiedExamples.Spacer.Screen

  @endpoint UnifiedExamples.Spacer.Endpoint

  test "spacer example exposes self-contained example metadata" do
    metadata = Spacer.metadata()

    assert metadata.id == :spacer_example_screen
    assert metadata.root_id == :spacer_example_screen_root
    assert metadata.title == "Spacer Widget Example"
    assert metadata.summary == "Focused content-oriented example using the local example shell"
    assert metadata.notes == "Spacer examples keep the local shell while foregrounding one primary spacer widget."
    assert metadata.widget == :spacer
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_spacer
    assert metadata.directory == "examples/spacer"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Spacer.Application,
             UnifiedExamples.Spacer.Endpoint,
             UnifiedExamples.Spacer.Router,
             UnifiedExamples.Spacer.Layouts,
             UnifiedExamples.Spacer.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Spacer.Screen,
             UnifiedExamples.Spacer.Theme,
             UnifiedExamples.Spacer.StyleProfile,
             UnifiedExamples.Spacer.Helpers
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
    assert metadata.interaction_demo.family == :click
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "spacer example renders the local shell and the focused widget" do
    assert {:ok, runtime_state} = Spacer.boot()
    assert {:ok, html} = Spacer.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :spacer_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Spacer Widget Example"
    assert html =~ "data-live-ui-widget=\"spacer\""
    assert html =~ "Highlight the spacing story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "spacer example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/spacer\""
    assert body =~ "Spacer Widget Example"
    assert body =~ "data-live-ui-widget=\"spacer\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
