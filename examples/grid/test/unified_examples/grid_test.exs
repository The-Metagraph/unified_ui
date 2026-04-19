defmodule UnifiedExamples.GridTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.Grid
  alias UnifiedExamples.Grid.Screen

  @endpoint UnifiedExamples.Grid.Endpoint

  test "grid example exposes self-contained example metadata" do
    metadata = Grid.metadata()

    assert metadata.id == :grid_example_screen
    assert metadata.root_id == :grid_example_screen_root
    assert metadata.title == "Grid Widget Example"
    assert metadata.summary == "Focused layout-oriented example using the local example shell"
    assert metadata.notes == "Grid examples keep the local shell while foregrounding one multi-cell layout surface."
    assert metadata.widget == :grid
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_grid
    assert metadata.directory == "examples/grid"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.Grid.Application,
             UnifiedExamples.Grid.Endpoint,
             UnifiedExamples.Grid.Router,
             UnifiedExamples.Grid.Layouts,
             UnifiedExamples.Grid.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.Grid.Screen,
             UnifiedExamples.Grid.Theme,
             UnifiedExamples.Grid.StyleProfile,
             UnifiedExamples.Grid.Helpers
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

  test "grid example renders the local shell and foregrounds one primary grid" do
    assert {:ok, runtime_state} = Grid.boot()
    assert {:ok, html} = Grid.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :grid_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"grid\""
    assert html =~ "Grid Widget Example"
    assert html =~ "CPU"
    assert html =~ "132ms"
    assert html =~ "Review the grid layout story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "grid example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/grid\""
    assert body =~ "Grid Widget Example"
    assert body =~ "data-live-ui-widget=\"grid\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
