defmodule WebUi.Layer do
  @moduledoc """
  Package-facing entrypoint for direct-use overlay and layered composition
  constructs in `web_ui`.
  """

  alias WebUi.Widgets.Layered

  @type responsibility ::
          :layer_surface
          | :overlay_surface
          | :modal_surface
          | :dismissal_surface

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [:layer_surface, :overlay_surface, :modal_surface, :dismissal_surface]
  end

  @spec modules() :: [module()]
  def modules, do: [Layered]

  @spec kinds() :: [atom()]
  def kinds, do: Layered.kinds()

  defdelegate overlay(base, layers, opts \\ []), to: Layered
  defdelegate dialog(content, opts \\ []), to: Layered
  defdelegate toast(content, opts \\ []), to: Layered
  defdelegate alert_dialog(content, opts \\ []), to: Layered
  defdelegate context_menu(items, opts \\ []), to: Layered
end
