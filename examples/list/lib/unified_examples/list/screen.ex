defmodule UnifiedExamples.List.Screen do
  @moduledoc """
  Shared-template list proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :list_example_screen,
    title: "List Widget Example",
    summary: "Focused data-oriented example using the shared suite shell",
    widget: :list,
    notes: "List examples foreground one canonical data list inside the shared shell."

  example_panel do
    list :list_example_primary_list do
      items([
        [
          id: :incident_1,
          label: "Database failover",
          description: "Primary cluster recovery in progress",
          selected?: true
        ],
        [
          id: :incident_2,
          label: "Queue backlog",
          description: "Background job latency elevated"
        ],
        [
          id: :incident_3,
          label: "Docs refresh",
          description: "Runbook update awaiting approval"
        ]
      ])

      selection_mode(:single)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
