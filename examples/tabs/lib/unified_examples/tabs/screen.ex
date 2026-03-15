defmodule UnifiedExamples.Tabs.Screen do
  @moduledoc """
  Shared-template tabs proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :tabs_example_screen,
    title: "Tabs Widget Example",
    summary: "Focused navigation-oriented example using the shared suite shell",
    widget: :tabs,
    notes: "Tabs examples keep the shared shell while foregrounding one canonical view switcher."

  example_panel do
    tabs :tabs_example_primary_tabs do
      items(summary: "Summary", deploys: "Deploys", alerts: "Alerts")
      active_item(:deploys)
      orientation(:horizontal)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
