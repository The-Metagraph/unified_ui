defmodule DesktopUi.Layout do
  @moduledoc """
  Advanced desktop layout and display-system widgets.
  """

  alias DesktopUi.Widget

  @kinds [:absolute, :canvas_surface, :scroll_region, :split_pane, :viewport]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec validation_state() :: map()
  def validation_state do
    %{
      advanced_display_systems: :ready,
      viewport_regions: :ready,
      split_pane_runtime: :ready,
      positioned_fragments: :ready
    }
  end

  @spec viewport(String.t() | atom(), Widget.t(), keyword()) :: Widget.t()
  def viewport(id, content, opts \\ []) do
    Widget.new(:viewport,
      id: id,
      metadata: metadata(opts, role: :viewport, focusable: false),
      attributes: %{
        axis: Keyword.get(opts, :axis, :vertical),
        offset: Keyword.get(opts, :offset, %{x: 0, y: 0}),
        clip: Keyword.get(opts, :clip, true),
        width: Keyword.get(opts, :width),
        height: Keyword.get(opts, :height),
        sync_group: Keyword.get(opts, :sync_group)
      },
      slot_children: %{content: [content]},
      events: events(scroll: Keyword.get(opts, :on_scroll)),
      styles: styles(opts)
    )
  end

  @spec scroll_region(String.t() | atom(), Widget.t(), keyword()) :: Widget.t()
  def scroll_region(id, content, opts \\ []) do
    Widget.new(:scroll_region,
      id: id,
      metadata: metadata(opts, role: :scroll_region, focusable: false),
      attributes: %{
        axis: Keyword.get(opts, :axis, :vertical),
        offset: Keyword.get(opts, :offset, %{x: 0, y: 0}),
        independent_scroll: Keyword.get(opts, :independent_scroll, false)
      },
      slot_children: %{content: [content]},
      events: events(scroll: Keyword.get(opts, :on_scroll)),
      styles: styles(opts)
    )
  end

  @spec split_pane(String.t() | atom(), Widget.t(), Widget.t(), keyword()) :: Widget.t()
  def split_pane(id, primary, secondary, opts \\ []) do
    Widget.new(:split_pane,
      id: id,
      metadata: metadata(opts, role: :split_pane, focusable: false),
      attributes: %{
        direction: Keyword.get(opts, :direction, :horizontal),
        ratio: Keyword.get(opts, :ratio, 0.5),
        resizable: Keyword.get(opts, :resizable, true),
        sync_scroll: Keyword.get(opts, :sync_scroll, false)
      },
      slot_children: %{primary: [primary], secondary: [secondary]},
      events: events(resize: Keyword.get(opts, :on_resize)),
      styles: styles(opts)
    )
  end

  @spec canvas_surface(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def canvas_surface(id, children \\ [], opts \\ []) do
    Widget.new(:canvas_surface,
      id: id,
      metadata:
        metadata(opts,
          role: :canvas_surface,
          positioning_mode: Keyword.get(opts, :positioning_mode, :absolute)
        ),
      attributes: %{
        width: Keyword.get(opts, :width),
        height: Keyword.get(opts, :height)
      },
      children: children,
      styles: styles(opts)
    )
  end

  @spec absolute(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def absolute(id, children \\ [], opts \\ []) do
    Widget.new(:absolute,
      id: id,
      metadata:
        metadata(opts,
          role: :absolute,
          positioning_mode: Keyword.get(opts, :positioning_mode, :absolute)
        ),
      attributes: %{
        x: Keyword.get(opts, :x, 0),
        y: Keyword.get(opts, :y, 0),
        z_index: Keyword.get(opts, :z_index, 0)
      },
      children: children,
      styles: styles(opts)
    )
  end

  defp metadata(opts, defaults),
    do: defaults |> Keyword.merge(Keyword.get(opts, :metadata, [])) |> Map.new()

  defp events(entries),
    do: entries |> Enum.reject(fn {_key, value} -> is_nil(value) end) |> Map.new()

  defp styles(opts), do: Map.new(Keyword.get(opts, :styles, []))
end
