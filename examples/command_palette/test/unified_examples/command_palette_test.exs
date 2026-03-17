defmodule UnifiedExamples.CommandPaletteTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.CommandPalette

  test "command palette example exposes standalone example metadata" do
    metadata = CommandPalette.metadata()

    assert metadata.id == :command_palette_example_screen
    assert metadata.root_id == :command_palette_example_screen_root
    assert metadata.widget == :command_palette
    assert metadata.app == :unified_example_command_palette
    assert metadata.directory == "examples/command_palette"
    assert metadata.interaction_demo.mode == :shared_trigger
    assert metadata.interaction_demo.family == :command
  end

  test "command palette example renders the shared shell and foregrounds one primary palette" do
    assert {:ok, runtime_state} = CommandPalette.boot()
    assert {:ok, html} = CommandPalette.render_html()

    assert runtime_state.mode == :canonical
    assert runtime_state.assigns.iur.id == :command_palette_example_screen_shell

    assert %UnifiedIUR.Element{kind: :command_palette} =
             Tree.find_by_id(runtime_state.assigns.iur, :command_palette_example_primary_palette)

    assert html =~ "data-live-ui-widget=\"box\""
    assert html =~ "data-live-ui-widget=\"command-palette\""
    assert html =~ "Command Palette Widget Example"
    assert html =~ "Open incident"
    assert html =~ "Assign owner"
    assert html =~ "Resolve incident"
    assert html =~ "Review the command palette command story"
    assert html =~ "Meaningful Interaction Story"
  end
end
