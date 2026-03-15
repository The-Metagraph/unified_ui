defmodule UnifiedExamples.CommandPalette.Screen do
  @moduledoc """
  Shared-template command palette proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :command_palette_example_screen,
    title: "Command Palette Widget Example",
    summary: "Focused navigation-oriented example using the shared suite shell",
    widget: :command_palette,
    notes:
      "Command palette examples foreground one canonical quick-action surface inside the shared shell."

  example_panel do
    command_palette :command_palette_example_primary_palette do
      items(
        open_incident: "Open incident",
        assign_owner: "Assign owner",
        resolve_incident: "Resolve incident"
      )

      label("Workspace commands")
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
