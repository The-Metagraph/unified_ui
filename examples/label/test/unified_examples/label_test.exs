defmodule UnifiedExamples.LabelTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Label
  alias UnifiedExamples.Label.Screen

  @endpoint UnifiedExamples.Label.Endpoint

  test "label example exposes self-contained example metadata" do
    metadata = Label.metadata()

    assert metadata.id == :label_example_screen
    assert metadata.root_id == :label_example_screen_root
    assert metadata.title == "Label Widget Example"
    assert metadata.summary == "Focused content-oriented example using the local example shell"
    assert metadata.notes == "Label examples keep the local shell while foregrounding one primary label widget."
    assert metadata.widget == :label
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_label
    assert metadata.directory == "examples/label"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Label.Application,
             UnifiedExamples.Label.Endpoint,
             UnifiedExamples.Label.Router,
             UnifiedExamples.Label.Layouts,
             UnifiedExamples.Label.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Label.Screen,
             UnifiedExamples.Label.Theme,
             UnifiedExamples.Label.StyleProfile,
             UnifiedExamples.Label.Helpers
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

  test "label example renders the local shell and the focused widget" do
    assert {:ok, runtime_state} = Label.boot()
    assert {:ok, html} = Label.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :label_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "Label Widget Example"
    assert html =~ "data-live-ui-widget=\"label\""
    assert html =~ "Assigned owner"
    assert html =~ "Highlight the label relationship"
    assert html =~ "Meaningful Interaction Story"
  end

  test "label example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/label\""
    assert body =~ "Label Widget Example"
    assert body =~ "data-live-ui-widget=\"label\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
