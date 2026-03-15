defmodule LiveUi.Component.Metadata do
  @moduledoc """
  Declares the shared metadata contract for native `live_ui` widgets.
  """

  @enforce_keys [:module, :family, :name]
  defstruct [:module, :family, :name, assigns: [], slots: []]

  @type t :: %__MODULE__{
          module: module(),
          family: atom(),
          name: atom(),
          assigns: [atom()],
          slots: [atom()]
        }

  @spec new(module(), keyword()) :: t()
  def new(module, opts) do
    %__MODULE__{
      module: module,
      family: Keyword.fetch!(opts, :family),
      name: Keyword.fetch!(opts, :name),
      assigns: Keyword.get(opts, :assigns, []),
      slots: Keyword.get(opts, :slots, [])
    }
  end
end
