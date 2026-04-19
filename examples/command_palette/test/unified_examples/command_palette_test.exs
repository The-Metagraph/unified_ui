defmodule UnifiedExamples.CommandPaletteTest do
  use ExUnit.Case, async: false

  import Phoenix.ConnTest

  alias UnifiedExamples.CommandPalette
  alias UnifiedExamples.CommandPalette.Screen

  @endpoint UnifiedExamples.CommandPalette.Endpoint

  test "command palette example exposes self-contained example metadata" do
    metadata = CommandPalette.metadata()

    assert metadata.id == :command_palette_example_screen
    assert metadata.root_id == :command_palette_example_screen_root
    assert metadata.title == "Command Palette Widget Example"
    assert metadata.summary == "Focused navigation-oriented example using the local example shell"
    assert metadata.notes ==
             "Command palette examples foreground one canonical quick-action surface inside the local shell."
    assert metadata.widget == :command_palette
    assert metadata.theme_id == :example_suite_default
    assert metadata.app == :unified_example_command_palette
    assert metadata.directory == "examples/command_palette"
    assert metadata.purpose == :widget_proof
    assert metadata.template_mode == :local
    refute metadata.uses_examples_shared?
    assert metadata.runtime_modules == [
             UnifiedExamples.CommandPalette.Application,
             UnifiedExamples.CommandPalette.Endpoint,
             UnifiedExamples.CommandPalette.Router,
             UnifiedExamples.CommandPalette.Layouts,
             UnifiedExamples.CommandPalette.Live
           ]
    assert metadata.authored_modules == [
             UnifiedExamples.CommandPalette.Screen,
             UnifiedExamples.CommandPalette.Theme,
             UnifiedExamples.CommandPalette.StyleProfile,
             UnifiedExamples.CommandPalette.Helpers
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
    assert metadata.interaction_demo.family == :command
    assert Screen.local_style_profile() == Screen.shared_style_profile()
  end

  test "command palette example renders the local shell and foregrounds one primary palette" do
    assert {:ok, runtime_state} = CommandPalette.boot()
    assert {:ok, html} = CommandPalette.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :command_palette_example_screen_shell
    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"command-palette\""
    assert html =~ "Command Palette Widget Example"
    assert html =~ "Open incident"
    assert html =~ "Assign owner"
    assert html =~ "Resolve incident"
    assert html =~ "Review the command palette command story"
    assert html =~ "Meaningful Interaction Story"
  end

  test "command palette example boots through its Phoenix LiveView app entrypoint" do
    conn = get(build_conn(), "/")
    body = html_response(conn, 200)

    assert body =~ "data-example-directory=\"examples/command_palette\""
    assert body =~ "Command Palette Widget Example"
    assert body =~ "data-live-ui-widget=\"command-palette\""
    assert body =~ "jido_run inspired live_ui example"
    assert body =~ "<meta name=\"csrf-token\""
    assert body =~ "/vendor/phoenix/phoenix.js"
    assert body =~ "/vendor/live_view/phoenix_live_view.js"
  end
end
