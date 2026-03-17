defmodule WebUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for the native `web_ui` widget surface.
  """

  @type responsibility ::
          :native_widget_surface
          | :layout_surface
          | :layer_surface
          | :style_hooks
          | :direct_use_surface

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [
      :native_widget_surface,
      :layout_surface,
      :layer_surface,
      :style_hooks,
      :direct_use_surface
    ]
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
