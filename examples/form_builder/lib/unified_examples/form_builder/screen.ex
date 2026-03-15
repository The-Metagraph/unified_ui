defmodule UnifiedExamples.FormBuilder.Screen do
  @moduledoc """
  Shared-template form_builder proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :form_builder_example_screen,
    title: "Form Builder Example",
    summary: "Focused form-oriented example using the shared suite shell",
    widget: :form_builder,
    notes:
      "Form builder examples keep the shared form shell while foregrounding one primary form workflow."

  example_form_panel do
    field_group :form_builder_example_identity_group do
      legend("Identity")

      field :form_builder_example_name_field do
        field_name(:display_name)
        label("Display name")

        text_input :form_builder_example_name_input do
          placeholder("Enter a display name")
          theme_ref(:example_suite_default)
          style_refs([:example_primary_input])
          tone(:surface)
          variant(:filled)
        end
      end
    end

    button :form_builder_example_submit do
      label("Save profile")
      theme_ref(:example_suite_default)
      style_refs([:example_primary_button])
      tone(:accent)
      variant(:quiet)
    end
  end
end
