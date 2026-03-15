defmodule UnifiedExamples.ContextMenu.Screen do
  @moduledoc """
  Shared-template context-menu proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @context_menu_options Fixtures.context_menu_options()

  use UnifiedExamples.Shared.Template,
    id: :context_menu_example_screen,
    title: "Context Menu Widget Example",
    summary: "Focused overlay example using the shared suite shell",
    widget: :context_menu,
    notes:
      "Context-menu examples foreground one canonical anchored action menu inside the shared shell."

  example_panel do
    box :context_menu_example_target do
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:panel)

      text :context_menu_example_target_label do
        value("Service health actions")
        theme_ref(:example_suite_default)
        tone(:surface)
        variant(:body)
      end
    end

    context_menu :context_menu_example_primary_context_menu do
      options(@context_menu_options)
      target_ref(:context_menu_example_target)
      visible?(true)
      placement(:bottom_start)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
