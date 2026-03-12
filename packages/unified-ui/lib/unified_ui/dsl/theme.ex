defmodule UnifiedUi.Dsl.Theme do
  @moduledoc """
  Target struct for theme DSL entities.

  Themes are named collections of style references that can optionally inherit
  from another theme.
  """

  defstruct [
    :name,
    :base_theme,
    styles: [],
    __meta__: []
  ]

  @type t :: %__MODULE__{
          name: atom(),
          base_theme: atom() | nil,
          styles: keyword(),
          __meta__: keyword()
        }
end
