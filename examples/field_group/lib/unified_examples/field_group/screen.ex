defmodule UnifiedExamples.FieldGroup.Screen do
  @moduledoc """
  Shared-template field_group proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :field_group_example_screen,
    title: "Field Group Example",
    summary: "Focused form-oriented example using the shared suite shell",
    widget: :field_group,
    notes:
      "Field group examples keep the shared form shell while foregrounding one grouped set of fields."

  example_form_panel do
    field_group :field_group_example_primary_group do
      legend("Notification preferences")

      field :field_group_example_email_field do
        field_name(:email)
        label("Email address")

        text_input :field_group_example_email_input do
          placeholder("you@example.com")
          theme_ref(:example_suite_default)
          style_refs([:example_primary_input])
          tone(:surface)
          variant(:filled)
        end
      end
    end
  end
end
