defmodule TerminalUi.Layout do
  @moduledoc """
  Advanced display-system constructors for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [:viewport, :split_pane, :scroll_region, :canvas_surface, :positioned]
  end

  @spec viewport(String.t() | atom(), Widget.t(), keyword()) :: Widget.t()
  def viewport(id, content, opts \\ []) do
    Widget.new(:viewport,
      id: id,
      family: :layout,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :viewport], opts),
          %{
            capability_profile: Keyword.get(opts, :capability_profile, :rich_terminal)
          }
        ),
      state: Builder.state(opts, %{current: Keyword.get(opts, :offset, 0)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :offset_binding)}),
      attributes: %{
        axis: Keyword.get(opts, :axis, :vertical),
        offset: Keyword.get(opts, :offset, 0),
        size: Keyword.get(opts, :size),
        bounded: Keyword.get(opts, :bounded, true)
      },
      slot_children: %{content: [content]},
      events: Builder.events(scroll: opts[:on_scroll]),
      styles: Builder.styles(opts)
    )
  end

  @spec scroll_region(String.t() | atom(), Widget.t(), keyword()) :: Widget.t()
  def scroll_region(id, content, opts \\ []) do
    Widget.new(:scroll_region,
      id: id,
      family: :layout,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :scroll_region], opts),
          %{
            degradation_strategy: Keyword.get(opts, :degradation_strategy, :paged_scroll)
          }
        ),
      state: Builder.state(opts, %{current: Keyword.get(opts, :offset, 0)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :offset_binding)}),
      attributes: %{
        axis: Keyword.get(opts, :axis, :vertical),
        offset: Keyword.get(opts, :offset, 0),
        show_scrollbar: Keyword.get(opts, :show_scrollbar, true)
      },
      slot_children: %{content: [content]},
      events: Builder.events(scroll: opts[:on_scroll]),
      styles: Builder.styles(opts)
    )
  end

  @spec split_pane(String.t() | atom(), Widget.t(), Widget.t(), keyword()) :: Widget.t()
  def split_pane(id, primary, secondary, opts \\ []) do
    Widget.new(:split_pane,
      id: id,
      family: :layout,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :split_pane], opts),
          %{
            capability_profile: Keyword.get(opts, :capability_profile, :rich_terminal)
          }
        ),
      state: Builder.state(opts, %{current: Keyword.get(opts, :ratio, 0.5)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :ratio_binding)}),
      attributes: %{
        axis: Keyword.get(opts, :axis, :horizontal),
        ratio: Keyword.get(opts, :ratio, 0.5),
        resizable: Keyword.get(opts, :resizable, true)
      },
      slots: [:primary, :secondary],
      slot_children: %{primary: [primary], secondary: [secondary]},
      events: Builder.events(change: opts[:on_resize], focus: opts[:on_focus]),
      styles: Builder.styles(opts)
    )
  end

  @spec canvas_surface(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def canvas_surface(id, fragments, opts \\ []) do
    Widget.new(:canvas_surface,
      id: id,
      family: :layout,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :canvas_surface), %{
          degradation_strategy: Keyword.get(opts, :degradation_strategy, :ascii_canvas)
        }),
      attributes: %{
        width: Keyword.get(opts, :width),
        height: Keyword.get(opts, :height),
        unit: Keyword.get(opts, :unit, :cell)
      },
      slot_children: %{default: fragments},
      styles: Builder.styles(opts)
    )
  end

  @spec positioned(String.t() | atom(), Widget.t(), keyword()) :: Widget.t()
  def positioned(id, content, opts \\ []) do
    Widget.new(:positioned,
      id: id,
      family: :layout,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :positioned), %{
          degradation_strategy: Keyword.get(opts, :degradation_strategy, :linearized_positioning)
        }),
      attributes: %{
        x: Keyword.get(opts, :x, 0),
        y: Keyword.get(opts, :y, 0),
        z: Keyword.get(opts, :z, 0)
      },
      slot_children: %{content: [content]},
      styles: Builder.styles(opts)
    )
  end

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
