defmodule WebUi.Renderer do
  @moduledoc """
  Package-facing entrypoint for canonical `UnifiedIUR` rendering boundaries.
  """

  @type responsibility ::
          :canonical_iur_entrypoint
          | :native_widget_reuse
          | :split_runtime_mapping

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [
      :canonical_iur_entrypoint,
      :native_widget_reuse,
      :split_runtime_mapping
    ]
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
