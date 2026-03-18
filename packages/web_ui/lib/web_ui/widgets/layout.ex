defmodule WebUi.Widgets.Layout do
  @moduledoc """
  Native layout and display-system widgets used by direct-native and canonical
  `web_ui` flows.
  """

  alias WebUi.Widgets.Builder

  @kinds [:row, :column, :grid, :stack, :viewport, :scroll_bar, :split_pane]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec row([WebUi.Widget.t() | map() | keyword()], keyword() | map()) :: WebUi.Widget.t()
  def row(children, opts \\ []) when is_list(children) do
    build_layout(:row, children, opts, :horizontal)
  end

  @spec column([WebUi.Widget.t() | map() | keyword()], keyword() | map()) :: WebUi.Widget.t()
  def column(children, opts \\ []) when is_list(children) do
    build_layout(:column, children, opts, :vertical)
  end

  @spec grid([WebUi.Widget.t() | map() | keyword()], keyword() | map()) :: WebUi.Widget.t()
  def grid(children, opts \\ []) when is_list(children) do
    opts = Builder.options(opts)

    Builder.widget(:grid,
      id: Builder.require_id!(opts, :grid),
      props: %{
        columns: Builder.option(opts, :columns),
        rows: Builder.option(opts, :rows),
        auto_flow: Builder.option(opts, :auto_flow, :row),
        gap: Builder.option(opts, :gap)
      },
      slots: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :layout, display_system?: true})
    )
  end

  @spec stack([WebUi.Widget.t() | map() | keyword()], keyword() | map()) :: WebUi.Widget.t()
  def stack(children, opts \\ []) when is_list(children) do
    opts = Builder.options(opts)

    Builder.widget(:stack,
      id: Builder.require_id!(opts, :stack),
      props: %{
        stacking: Builder.option(opts, :stacking, :overlay),
        align: Builder.option(opts, :align),
        justify: Builder.option(opts, :justify)
      },
      slots: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :layout, display_system?: true})
    )
  end

  @spec viewport(WebUi.Widget.t() | map() | keyword(), keyword() | map()) :: WebUi.Widget.t()
  def viewport(content, opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:viewport,
      id: Builder.require_id!(opts, :viewport),
      props: %{
        axis: Builder.option(opts, :axis, :vertical),
        offset: normalize_offset(Builder.option(opts, :offset, 0)),
        clip?: Builder.option(opts, :clip?, true),
        scrollbars: Builder.option(opts, :scrollbars, :auto),
        width: Builder.option(opts, :width),
        height: Builder.option(opts, :height),
        sync_group: Builder.option(opts, :sync_group),
        independent_scroll?: Builder.option(opts, :independent_scroll?)
      },
      slots: Builder.slot_map([{:content, content}]),
      state: Builder.state(opts, [:disabled?, :focused?, :scrolled?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, scroll: :scroll),
      metadata: Builder.metadata(opts, %{native_surface: :layout, display_system?: true})
    )
  end

  @spec scroll_bar(keyword() | map()) :: WebUi.Widget.t()
  def scroll_bar(opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:scroll_bar,
      id: Builder.require_id!(opts, :scroll_bar),
      props: %{
        orientation: Builder.option(opts, :orientation, :vertical),
        position: normalize_position(Builder.option(opts, :position, 0)),
        viewport_size: Builder.option(opts, :viewport_size),
        content_size: Builder.option(opts, :content_size),
        viewport_ref: Builder.option(opts, :viewport_ref),
        sync_group: Builder.option(opts, :sync_group)
      },
      state: Builder.state(opts, [:disabled?, :focused?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, scroll: :scroll),
      metadata: Builder.metadata(opts, %{native_surface: :layout, display_system?: true})
    )
  end

  @spec split_pane(
          WebUi.Widget.t() | map() | keyword(),
          WebUi.Widget.t() | map() | keyword(),
          keyword() | map()
        ) :: WebUi.Widget.t()
  def split_pane(primary, secondary, opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:split_pane,
      id: Builder.require_id!(opts, :split_pane),
      props: %{
        direction: Builder.option(opts, :direction, :horizontal),
        ratio: Builder.option(opts, :ratio, 0.5),
        resizable?: Builder.option(opts, :resizable?, true),
        min_primary: Builder.option(opts, :min_primary),
        min_secondary: Builder.option(opts, :min_secondary),
        primary_size: Builder.option(opts, :primary_size),
        secondary_size: Builder.option(opts, :secondary_size),
        divider: normalize_divider(opts),
        sync_scroll: Builder.option(opts, :sync_scroll)
      },
      slots:
        Builder.slot_map([
          {:primary, primary},
          {:secondary, secondary}
        ]),
      state: Builder.state(opts, [:disabled?, :focused?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, resize: :resize),
      metadata: Builder.metadata(opts, %{native_surface: :layout, display_system?: true})
    )
  end

  defp build_layout(kind, children, opts, direction) do
    opts = Builder.options(opts)

    Builder.widget(kind,
      id: Builder.require_id!(opts, kind),
      props: %{
        direction: direction,
        gap: Builder.option(opts, :gap),
        align: Builder.option(opts, :align),
        justify: Builder.option(opts, :justify)
      },
      slots: %{default: Builder.children!(children)},
      state: Builder.state(opts),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :layout})
    )
  end

  defp normalize_offset(value) when is_integer(value), do: %{x: 0, y: value}
  defp normalize_offset({x, y}) when is_integer(x) and is_integer(y), do: %{x: x, y: y}

  defp normalize_offset(value) when is_map(value) or is_list(value) do
    value = Builder.options(value)

    %{
      x: Builder.option(value, :x, 0),
      y: Builder.option(value, :y, 0)
    }
  end

  defp normalize_position(value) when is_number(value), do: %{start: value, end: value}

  defp normalize_position({start_pos, end_pos})
       when is_number(start_pos) and is_number(end_pos) do
    %{start: start_pos, end: end_pos}
  end

  defp normalize_position(value), do: value

  defp normalize_divider(opts) do
    opts
    |> Builder.option(:divider, %{})
    |> Builder.options()
    |> Builder.maybe_put(:size, Builder.option(opts, :divider_size))
    |> Builder.maybe_put(:style, Builder.option(opts, :divider_style))
  end
end
