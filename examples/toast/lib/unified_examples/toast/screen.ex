defmodule UnifiedExamples.Toast.Screen do
  @moduledoc """
  Shared-template toast proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @toast_snapshot Fixtures.toast_snapshot()

  use UnifiedExamples.Shared.Template,
    id: :toast_example_screen,
    title: "Toast Widget Example",
    summary: "Focused overlay example using the shared suite shell",
    widget: :toast,
    notes:
      "Toast examples foreground one canonical transient notification surface inside the shared shell."

  example_panel do
    button :toast_example_trigger do
      label("Trigger sync notice")
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:quiet)
    end

    toast :toast_example_primary_toast do
      title(@toast_snapshot.title)
      message(@toast_snapshot.message)
      severity(@toast_snapshot.severity)
      placement(@toast_snapshot.placement)
      trigger_ref(:toast_example_trigger)
      visible?(true)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
