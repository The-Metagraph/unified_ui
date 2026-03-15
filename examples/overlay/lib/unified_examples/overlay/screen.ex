defmodule UnifiedExamples.Overlay.Screen do
  @moduledoc """
  Shared-template overlay proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @dialog_snapshot Fixtures.dialog_snapshot()
  @toast_snapshot Fixtures.toast_snapshot()
  @overlay_snapshot Fixtures.overlay_snapshot()

  use UnifiedExamples.Shared.Template,
    id: :overlay_example_screen,
    title: "Overlay Widget Example",
    summary: "Focused overlay example using the shared suite shell",
    widget: :overlay,
    notes: "Overlay examples foreground one canonical layered surface inside the shared shell."

  example_panel do
    box :overlay_example_base_panel do
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:panel)

      text :overlay_example_base_heading do
        value(@overlay_snapshot.base_title)
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end
    end

    box :overlay_example_dialog_content do
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:panel)

      text :overlay_example_dialog_copy do
        value(@dialog_snapshot.copy)
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end
    end

    dialog :overlay_example_dialog do
      title(@dialog_snapshot.title)
      content_ref(:overlay_example_dialog_content)
      visible?(true)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end

    toast :overlay_example_toast do
      title(@toast_snapshot.title)
      message(@toast_snapshot.message)
      severity(@toast_snapshot.severity)
      placement(@toast_snapshot.placement)
      visible?(true)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end

    overlay :overlay_example_primary_overlay do
      base_ref(:overlay_example_base_panel)
      layer_refs([:overlay_example_dialog, :overlay_example_toast])
      background_fill(@overlay_snapshot.background_fill)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
