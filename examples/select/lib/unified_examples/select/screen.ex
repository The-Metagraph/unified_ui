defmodule UnifiedExamples.Select.Screen do
  @moduledoc """
  Shared-template select proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :select_example_screen,
    title: "Select Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :select,
    notes:
      "Select examples keep the shared form shell while foregrounding one menu-based choice control."

  example_form_panel do
    field :select_example_primary_field do
      field_name(:region)
      label("Region")

      select :select_example_primary_input do
        options(us: "United States", eu: "Europe", apac: "APAC")
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
