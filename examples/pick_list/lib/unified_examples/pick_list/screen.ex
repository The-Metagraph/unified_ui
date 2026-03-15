defmodule UnifiedExamples.PickList.Screen do
  @moduledoc """
  Shared-template pick_list proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :pick_list_example_screen,
    title: "Pick List Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :pick_list,
    notes:
      "Pick list examples keep the shared form shell while foregrounding one multi-select control."

  example_form_panel do
    field :pick_list_example_primary_field do
      field_name(:labels)
      label("Labels")

      pick_list :pick_list_example_primary_input do
        options(alpha: "Alpha", beta: "Beta", gamma: "Gamma")
        multiple?(true)
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
