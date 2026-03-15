defmodule LiveUi.Renderer do
  @moduledoc """
  Package-facing entrypoint for canonical `UnifiedIUR` rendering.
  """

  alias UnifiedIUR.Element

  @spec accepts() :: module()
  def accepts, do: Element

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
