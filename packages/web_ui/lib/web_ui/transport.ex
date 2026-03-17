defmodule WebUi.Transport do
  @moduledoc """
  Package-facing entrypoint for canonical boundary transport boundaries.
  """

  @type responsibility ::
          :canonical_boundary_translation
          | :phoenix_elm_bridge
          | :native_event_translation

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [
      :canonical_boundary_translation,
      :phoenix_elm_bridge,
      :native_event_translation
    ]
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
