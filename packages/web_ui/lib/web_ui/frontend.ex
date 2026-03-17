defmodule WebUi.Frontend do
  @moduledoc """
  Package-facing entrypoint for the Elm frontend runtime boundary.
  """

  @type responsibility ::
          :elm_rendering
          | :bounded_local_state
          | :browser_bridge
          | :frontend_bootstrap

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [
      :elm_rendering,
      :bounded_local_state,
      :browser_bridge,
      :frontend_bootstrap
    ]
  end

  @spec assets_root() :: String.t()
  def assets_root do
    Path.expand("../assets/elm", __DIR__)
  end

  @spec entry_module() :: String.t()
  def entry_module do
    "WebUi.Main"
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
