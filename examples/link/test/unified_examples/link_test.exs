defmodule UnifiedExamples.LinkTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Link
  alias UnifiedExamples.Link.Screen

  @endpoint UnifiedExamples.Link.Endpoint

  test "link example exposes self-contained example metadata" do
    metadata = Link.metadata()

    assert metadata.id == :link_example_screen
    assert metadata.root_id == :link_example_screen_root
    assert metadata.title == "Link Widget Example"
    assert metadata.summary == "Focused content-oriented example using the local example shell"
    assert metadata.notes == "Link examples keep the local shell while foregrounding one primary link widget."
    assert metadata.widget == :link
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_link
    assert metadata.directory == "examples/link"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Link.Application,
             UnifiedExamples.Link.Endpoint,
             UnifiedExamples.Link.Router,
             UnifiedExamples.Link.Layouts,
             UnifiedExamples.Link.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Link.Screen,
             UnifiedExamples.Link.Theme,
             UnifiedExamples.Link.StyleProfile,
             UnifiedExamples.Link.Helpers
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

  test "link example renders the local shell and the focused widget" do
    assert {:ok, runtime_state} = Link.boot()
    assert {:ok, html} = Link.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :link_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Link Widget Example"
    assert html =~ "data-live-ui-widget=\"link\""
    assert html =~ "Open the example documentation"
    assert html =~ "Review the link story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "link example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/link\""
    assert body =~ "Link Widget Example"
    assert body =~ "data-live-ui-widget=\"link\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
