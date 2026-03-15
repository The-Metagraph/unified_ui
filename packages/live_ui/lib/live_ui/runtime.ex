defmodule LiveUi.Runtime do
  @moduledoc """
  Package-facing entrypoint for the server-authoritative LiveView runtime.
  """

  @type capability ::
          :native_mount
          | :native_render
          | :event_handling
          | :browser_bridge_placeholders

  @spec capabilities() :: [capability()]
  def capabilities do
    [:native_mount, :native_render, :event_handling, :browser_bridge_placeholders]
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
