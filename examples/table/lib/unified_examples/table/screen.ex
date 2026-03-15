defmodule UnifiedExamples.Table.Screen do
  @moduledoc """
  Shared-template table proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  use UnifiedExamples.Shared.Template,
    id: :table_example_screen,
    title: "Table Widget Example",
    summary: "Focused data-oriented example using the shared suite shell",
    widget: :table,
    notes: "Table examples foreground one canonical tabular dataset inside the shared shell."

  example_panel do
    table :table_example_primary_table do
      table_columns(Fixtures.operations_table_columns())
      table_rows(Fixtures.operations_table_rows())
      empty_state("No services available")
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
