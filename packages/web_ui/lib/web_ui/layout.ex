defmodule WebUi.Layout do
  @moduledoc """
  Package-facing entrypoint for direct-use layout and display-system constructs
  in `web_ui`.
  """

  alias WebUi.Widgets.Layout, as: NativeLayout

  @type responsibility ::
          :display_system_surface
          | :layout_surface
          | :viewport_surface
          | :split_surface

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [:display_system_surface, :layout_surface, :viewport_surface, :split_surface]
  end

  @spec modules() :: [module()]
  def modules, do: [NativeLayout]

  @spec kinds() :: [atom()]
  def kinds, do: NativeLayout.kinds()

  defdelegate row(children, opts \\ []), to: NativeLayout
  defdelegate column(children, opts \\ []), to: NativeLayout
  defdelegate grid(children, opts \\ []), to: NativeLayout
  defdelegate stack(children, opts \\ []), to: NativeLayout
  defdelegate viewport(content, opts \\ []), to: NativeLayout
  defdelegate scroll_bar(opts \\ []), to: NativeLayout
  defdelegate split_pane(primary, secondary, opts \\ []), to: NativeLayout
end
