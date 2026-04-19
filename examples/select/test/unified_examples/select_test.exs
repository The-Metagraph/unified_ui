defmodule UnifiedExamples.SelectTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Select
  alias UnifiedExamples.Select.Screen

  @endpoint UnifiedExamples.Select.Endpoint

  test "select example exposes self-contained example metadata" do
    metadata = Select.metadata()

    assert metadata.id == :select_example_screen
    assert metadata.root_id == :select_example_screen_root
    assert metadata.title == "Select Widget Example"
    assert metadata.summary == "Focused input-oriented example using the local example shell"
    assert metadata.notes == "Select examples keep the local form shell while foregrounding one menu-based choice control."
    assert metadata.widget == :select
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_select
    assert metadata.directory == "examples/select"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Select.Application,
             UnifiedExamples.Select.Endpoint,
             UnifiedExamples.Select.Router,
             UnifiedExamples.Select.Layouts,
             UnifiedExamples.Select.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Select.Screen,
             UnifiedExamples.Select.Theme,
             UnifiedExamples.Select.StyleProfile,
             UnifiedExamples.Select.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :selection
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "select example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = Select.boot()
    assert {:ok, html} = Select.render_html()

    assert runtime_state.assigns.iur.id == :select_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Select Widget Example"
    assert html =~ "data-live-ui-widget=\"select\""
    assert html =~ "United States"
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_selection_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "select example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/select\""
    assert body =~ "Select Widget Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
