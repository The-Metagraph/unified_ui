defmodule UnifiedExamples.RadioGroup.Screen do
  @moduledoc """
  Shared-template radio_group proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :radio_group_example_screen,
    title: "Radio Group Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :radio_group,
    notes:
      "Radio group examples keep the shared form shell while foregrounding one exclusive choice control."

  example_form_panel do
    field :radio_group_example_primary_field do
      field_name(:role)
      label("Role")

      radio_group :radio_group_example_primary_input do
        options(admin: "Admin", member: "Member", viewer: "Viewer")
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
