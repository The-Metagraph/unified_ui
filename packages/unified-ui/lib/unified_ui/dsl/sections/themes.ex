defmodule UnifiedUi.Dsl.Sections.Themes do
  @moduledoc """
  Baseline authored theming section for `UnifiedUi` modules.
  """

  @section %Spark.Dsl.Section{
    name: :themes,
    describe: """
    Declare baseline authored theme defaults and later theme-extension hooks.
    """,
    schema: [
      default_theme: [
        type: :atom,
        required: false,
        doc: "Optional default theme reference for the authored module."
      ],
      inherit?: [
        type: :boolean,
        required: false,
        default: true,
        doc: "Whether authored constructs inherit theme defaults by default."
      ],
      summary: [
        type: :string,
        required: false,
        doc: "Optional summary of the theme intent for the authored module."
      ]
    ]
  }

  @spec section() :: Spark.Dsl.Section.t()
  def section, do: @section
end
