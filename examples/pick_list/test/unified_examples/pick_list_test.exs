defmodule UnifiedExamples.PickListTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.PickList
  alias UnifiedExamples.PickList.Screen

  @endpoint UnifiedExamples.PickList.Endpoint

  test "pick_list example exposes self-contained example metadata" do
    metadata = PickList.metadata()

    assert metadata.id == :pick_list_example_screen
    assert metadata.root_id == :pick_list_example_screen_root
    assert metadata.title == "Pick List Widget Example"
    assert metadata.summary == "Focused input-oriented example using the local example shell"
    assert metadata.notes == "Pick list examples keep the local form shell while foregrounding one multi-select control."
    assert metadata.widget == :pick_list
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_pick_list
    assert metadata.directory == "examples/pick_list"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.PickList.Application,
             UnifiedExamples.PickList.Endpoint,
             UnifiedExamples.PickList.Router,
             UnifiedExamples.PickList.Layouts,
             UnifiedExamples.PickList.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.PickList.Screen,
             UnifiedExamples.PickList.Theme,
             UnifiedExamples.PickList.StyleProfile,
             UnifiedExamples.PickList.Helpers
           ]
    assert metadata.interaction_demo.mode == :form_shell
    assert metadata.interaction_demo.family == :selection
    assert metadata.interaction_demo.source == :form_shell
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "pick_list example renders the local form shell and the focused widget" do
    assert {:ok, runtime_state} = PickList.boot()
    assert {:ok, html} = PickList.render_html()

    assert runtime_state.assigns.iur.id == :pick_list_example_screen_shell
    assert html =~ "data-live-ui-widget=\"form-builder\""
    assert html =~ "Pick List Widget Example"
    assert html =~ "data-live-ui-widget=\"select\""
    assert html =~ "Alpha"
    assert html =~ "multiple"
    assert html =~ "data-live-ui-variant=\"filled\""
    assert html =~ "phx-change=\"canonical_selection_interaction\""
    assert html =~ "Meaningful Interaction Story"
  end

  test "pick_list example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/pick_list\""
    assert body =~ "Pick List Widget Example"
    assert body =~ "data-live-ui-widget=\"form-builder\""
    assert body =~ "jido_run inspired live_ui example"
  end
end
