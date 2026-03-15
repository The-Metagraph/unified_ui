defmodule UnifiedExamples.Link.Screen do
  @moduledoc """
  Shared-template link proof for the standalone example-app suite.
  """

  use UnifiedExamples.Shared.Template,
    id: :link_example_screen,
    title: "Link Widget Example",
    summary: "Focused content-oriented example using the shared suite shell",
    widget: :link,
    notes: "Link examples keep the shared shell while foregrounding one primary link widget."

  example_panel do
    link :link_example_primary_link do
      label("Open the shared documentation")
      target("https://specled.dev/home")
      external?(true)
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:inline)
    end
  end
end
