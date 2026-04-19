defmodule UnifiedExamples.ContentTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Content
  alias UnifiedExamples.Content.Screen

  @endpoint UnifiedExamples.Content.Endpoint

  test "content example exposes self-contained example metadata" do
    metadata = Content.metadata()

    assert metadata.id == :content_example_screen
    assert metadata.root_id == :content_example_screen_root
    assert metadata.title == "Content Widget Example"
    assert metadata.summary == "Focused content-oriented example using the local example shell"
    assert metadata.notes == "Content examples keep the local shell while foregrounding one primary content container."
    assert metadata.widget == :content
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_content
    assert metadata.directory == "examples/content"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Content.Application,
             UnifiedExamples.Content.Endpoint,
             UnifiedExamples.Content.Router,
             UnifiedExamples.Content.Layouts,
             UnifiedExamples.Content.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Content.Screen,
             UnifiedExamples.Content.Theme,
             UnifiedExamples.Content.StyleProfile,
             UnifiedExamples.Content.Helpers
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

  test "content example renders the local shell and the focused widget" do
    assert {:ok, runtime_state} = Content.boot()
    assert {:ok, html} = Content.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :content_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Content Widget Example"
    assert html =~ "data-live-ui-widget=\"content\""
    assert html =~ "Self-contained content block"
    assert html =~ "Review the content story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "content example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/content\""
    assert body =~ "Content Widget Example"
    assert body =~ "data-live-ui-widget=\"content\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
