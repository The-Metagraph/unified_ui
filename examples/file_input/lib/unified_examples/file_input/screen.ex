defmodule UnifiedExamples.FileInput.Screen do
  @moduledoc """
  Shared-template file_input proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :file_input_example_screen,
    title: "File Input Widget Example",
    summary: "Focused input-oriented example using the shared suite shell",
    widget: :file_input,
    notes:
      "File input examples keep the shared form shell while foregrounding one file picker control."

  example_form_panel do
    field :file_input_example_primary_field do
      field_name(:attachment)
      label("Attachment")

      file_input :file_input_example_primary_input do
        accept(["image/png", "application/pdf"])
        multiple?(true)
        capture("environment")
        theme_ref(:example_suite_default)
        style_refs([:example_primary_input])
        tone(:surface)
        variant(:filled)
      end
    end
  end
end
