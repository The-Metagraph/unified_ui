defmodule UnifiedExamples.Menu.Screen do
  @moduledoc """
  Shared-template menu proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :menu_example_screen,
    title: "Menu Widget Example",
    summary: "Focused navigation-oriented example using the shared suite shell",
    widget: :menu,
    notes: "Menu examples foreground one canonical navigation rail inside the shared shell."

  example_panel do
    menu :menu_example_primary_menu do
      items(overview: "Overview", incidents: "Incidents", releases: "Releases")
      active_item(:incidents)
      orientation(:vertical)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
