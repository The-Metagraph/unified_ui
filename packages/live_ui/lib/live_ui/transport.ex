defmodule LiveUi.Transport do
  @moduledoc """
  Package-facing entrypoint for boundary transport translation helpers.
  """

  @type mode :: :native_local | :canonical_boundary

  @spec modes() :: [mode()]
  def modes do
    [:native_local, :canonical_boundary]
  end

  @spec integration_points() :: [atom()]
  def integration_points do
    [:native_liveview_events, :browser_hooks, :canonical_boundary_translation]
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
