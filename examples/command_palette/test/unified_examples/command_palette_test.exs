defmodule UnifiedExamples.CommandPaletteTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Tree
  alias UnifiedExamples.CommandPalette

  test "command palette example exposes standalone example metadata" do
    assert CommandPalette.metadata() == %{
             id: :command_palette_example_screen,
             root_id: :command_palette_example_screen_root,
             title: "Command Palette Widget Example",
             summary: "Focused navigation-oriented example using the shared suite shell",
             notes:
               "Command palette examples foreground one canonical quick-action surface inside the shared shell.",
             widget: :command_palette,
             theme_id: :example_suite_default,
             app: :unified_example_command_palette,
             directory: "examples/command_palette",
             purpose: :widget_proof
           }
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
  end
end
