defmodule UnifiedExamples.TextTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Text
  alias UnifiedExamples.Text.Screen

  @endpoint UnifiedExamples.Text.Endpoint

  test "text example exposes self-contained example metadata" do
    metadata = Text.metadata()

    assert metadata.id == :text_example_screen
    assert metadata.root_id == :text_example_screen_root
    assert metadata.title == "Text Widget Example"
    assert metadata.summary == "Focused content-oriented example using the local example shell"
    assert metadata.notes == "Text examples keep the local shell while foregrounding one primary content widget."
    assert metadata.widget == :text
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_text
    assert metadata.directory == "examples/text"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Text.Application,
             UnifiedExamples.Text.Endpoint,
             UnifiedExamples.Text.Router,
             UnifiedExamples.Text.Layouts,
             UnifiedExamples.Text.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Text.Screen,
             UnifiedExamples.Text.Theme,
             UnifiedExamples.Text.StyleProfile,
             UnifiedExamples.Text.Helpers
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

  test "text example renders the local shell and the focused content widget" do
    assert {:ok, runtime_state} = Text.boot()
    assert {:ok, html} = Text.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :text_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Text Widget Example"
    assert html =~ "Self-contained text example"
    assert html =~ "data-live-ui-widget=\"text\""
    assert html =~ "data-live-ui-variant=\"headline\""
    assert html =~ "Highlight the text story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "text example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/text\""
    assert body =~ "Text Widget Example"
    assert body =~ "data-live-ui-widget=\"text\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
