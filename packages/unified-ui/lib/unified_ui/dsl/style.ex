defmodule UnifiedUi.Dsl.Style do
  @moduledoc """
  Target struct for style DSL entities.

  This struct stores the parsed data from a style entity definition.
  It is used internally by the DSL and resolver.

  ## Fields

  * `name` - The unique name of the style
  * `extends` - Optional parent style name for inheritance
  * `attributes` - The style attributes as a keyword list
  * `__meta__` - Metadata from the DSL parser

  ## Examples

      iex> %Style{name: :header, attributes: [fg: :cyan, attrs: [:bold]]}
      %Style{name: :header, extends: nil, attributes: [fg: :cyan, attrs: [:bold]]}

  """
  defstruct [
    :name,
    :extends,
    attributes: [],
    __meta__: []
  ]

  @type t :: %__MODULE__{
          name: atom(),
          extends: atom() | nil,
          attributes: keyword(),
          __meta__: keyword()
        }
end
