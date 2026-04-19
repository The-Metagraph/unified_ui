defmodule UnifiedExamples.SeparatorTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Separator
  alias UnifiedExamples.Separator.Screen

  @endpoint UnifiedExamples.Separator.Endpoint

  test "separator example exposes self-contained example metadata" do
    metadata = Separator.metadata()

    assert metadata.id == :separator_example_screen
    assert metadata.root_id == :separator_example_screen_root
    assert metadata.title == "Separator Widget Example"
    assert metadata.summary == "Focused content-oriented example using the local example shell"
    assert metadata.notes == "Separator examples keep the local shell while foregrounding one primary separator widget."
    assert metadata.widget == :separator
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_separator
    assert metadata.directory == "examples/separator"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Separator.Application,
             UnifiedExamples.Separator.Endpoint,
             UnifiedExamples.Separator.Router,
             UnifiedExamples.Separator.Layouts,
             UnifiedExamples.Separator.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Separator.Screen,
             UnifiedExamples.Separator.Theme,
             UnifiedExamples.Separator.StyleProfile,
             UnifiedExamples.Separator.Helpers
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

  test "separator example renders the local shell and the focused widget" do
    assert {:ok, runtime_state} = Separator.boot()
    assert {:ok, html} = Separator.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :separator_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Separator Widget Example"
    assert html =~ "data-live-ui-widget=\"separator\""
    assert html =~ "Highlight the separator story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "separator example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/separator\""
    assert body =~ "Separator Widget Example"
    assert body =~ "data-live-ui-widget=\"separator\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
