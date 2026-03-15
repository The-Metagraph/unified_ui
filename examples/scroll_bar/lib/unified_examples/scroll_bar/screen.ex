defmodule UnifiedExamples.ScrollBar.Screen do
  @moduledoc """
  Shared-template scroll-bar proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @document_lines Fixtures.viewport_document_lines()
  @scroll_line_one Enum.at(@document_lines, 0)
  @scroll_line_two Enum.at(@document_lines, 1)
  @scroll_line_three Enum.at(@document_lines, 2)
  @scroll_line_four Enum.at(@document_lines, 3)
  @scroll_bar_snapshot Fixtures.scroll_bar_snapshot()

  use UnifiedExamples.Shared.Template,
    id: :scroll_bar_example_screen,
    title: "Scroll Bar Widget Example",
    summary: "Focused display-system example using the shared suite shell",
    widget: :scroll_bar,
    notes:
      "Scroll-bar examples foreground one canonical viewport control inside the shared shell."

  example_panel do
    box :scroll_bar_example_document do
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:panel)

      text :scroll_bar_example_document_heading do
        value("Scrollable incident log")
        theme_ref(:example_suite_default)
        tone(:accent)
        variant(:body)
      end

      text :scroll_bar_example_document_line_one do
        value(@scroll_line_one)
      end

      text :scroll_bar_example_document_line_two do
        value(@scroll_line_two)
      end

      text :scroll_bar_example_document_line_three do
        value(@scroll_line_three)
      end

      text :scroll_bar_example_document_line_four do
        value(@scroll_line_four)
      end
    end

    viewport :scroll_bar_example_support_viewport do
      content_ref(:scroll_bar_example_document)
      width(72)
      height(@scroll_bar_snapshot.viewport_size)
      offset({0, @scroll_bar_snapshot.position})
      clip?(true)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end

    scroll_bar :scroll_bar_example_primary_scroll_bar do
      target_ref(:scroll_bar_example_support_viewport)
      position(@scroll_bar_snapshot.position)
      viewport_size(@scroll_bar_snapshot.viewport_size)
      content_size(@scroll_bar_snapshot.content_size)
      orientation(@scroll_bar_snapshot.orientation)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
