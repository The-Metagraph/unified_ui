defmodule UnifiedExamples.SplitPaneTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.SplitPane
  alias UnifiedExamples.SplitPane.Screen

  @endpoint UnifiedExamples.SplitPane.Endpoint

  test "split pane example exposes self-contained example metadata" do
    metadata = SplitPane.metadata()

    assert metadata.id == :split_pane_example_screen
    assert metadata.root_id == :split_pane_example_screen_root
    assert metadata.title == "Split Pane Widget Example"
    assert metadata.summary == "Focused display-system example using the local example shell"
    assert metadata.notes == "Split-pane examples foreground one canonical dual-region layout inside the local shell."
    assert metadata.widget == :split_pane
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_split_pane
    assert metadata.directory == "examples/split_pane"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.SplitPane.Application,
             UnifiedExamples.SplitPane.Endpoint,
             UnifiedExamples.SplitPane.Router,
             UnifiedExamples.SplitPane.Layouts,
             UnifiedExamples.SplitPane.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.SplitPane.Screen,
             UnifiedExamples.SplitPane.Theme,
             UnifiedExamples.SplitPane.StyleProfile,
             UnifiedExamples.SplitPane.Helpers
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
    assert metadata.interaction_demo.family == :focus
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "split pane example renders the local shell and foregrounds one primary split pane" do
    assert {:ok, runtime_state} = SplitPane.boot()
    assert {:ok, html} = SplitPane.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :split_pane_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"split-pane\""
    assert html =~ "Split Pane Widget Example"
    assert html =~ "Active incidents"
    assert html =~ "Responder notes"
    assert html =~ "Inspect the split pane display story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "split pane example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/split_pane\""
    assert body =~ "Split Pane Widget Example"
    assert body =~ "data-live-ui-widget=\"split-pane\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
