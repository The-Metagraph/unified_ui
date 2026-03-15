defmodule UnifiedExamples.Dialog.Screen do
  @moduledoc """
  Shared-template dialog proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @dialog_snapshot Fixtures.dialog_snapshot()

  use UnifiedExamples.Shared.Template,
    id: :dialog_example_screen,
    title: "Dialog Widget Example",
    summary: "Focused overlay example using the shared suite shell",
    widget: :dialog,
    notes: "Dialog examples foreground one canonical modal surface inside the shared shell."

  example_panel do
    button :dialog_example_open_button do
      label(@dialog_snapshot.trigger_label)
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:quiet)
    end

    box :dialog_example_content do
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:panel)

      text :dialog_example_content_copy do
        value(@dialog_snapshot.copy)
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end
    end

    dialog :dialog_example_primary_dialog do
      title(@dialog_snapshot.title)
      content_ref(:dialog_example_content)
      trigger_ref(:dialog_example_open_button)
      visible?(true)
      modal?(true)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
