defmodule UnifiedExamples.Viewport.Screen do
  @moduledoc """
  Shared-template viewport proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @document_lines Fixtures.viewport_document_lines()
  @document_line_one Enum.at(@document_lines, 0)
  @document_line_two Enum.at(@document_lines, 1)
  @document_line_three Enum.at(@document_lines, 2)
  @document_line_four Enum.at(@document_lines, 3)

  use UnifiedExamples.Shared.Template,
    id: :viewport_example_screen,
    title: "Viewport Widget Example",
    summary: "Focused display-system example using the shared suite shell",
    widget: :viewport,
    notes: "Viewport examples foreground one canonical clipped region inside the shared shell."

  example_panel do
    box :viewport_example_document do
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:panel)

      text :viewport_example_document_heading do
        value("Incident timeline")
        theme_ref(:example_suite_default)
        tone(:accent)
        variant(:body)
      end

      text :viewport_example_document_line_one do
        value(@document_line_one)
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end

      text :viewport_example_document_line_two do
        value(@document_line_two)
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end

      text :viewport_example_document_line_three do
        value(@document_line_three)
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end

      text :viewport_example_document_line_four do
        value(@document_line_four)
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end
    end

    viewport :viewport_example_primary_viewport do
      content_ref(:viewport_example_document)
      width(72)
      height(12)
      offset({0, 6})
      clip?(true)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
