defmodule TerminalUi.Layer do
  @moduledoc """
  Layered runtime constructors for overlays and positioned terminal content.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [:overlay, :popover, :context_menu, :absolute]
  end

  @spec overlay(String.t() | atom(), Widget.t(), [Widget.t()], keyword()) :: Widget.t()
  def overlay(id, base, overlays, opts \\ []) do
    Widget.new(:overlay,
      id: id,
      family: :layout,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :overlay), %{
          overlay_role: :overlay,
          capability_profile: Keyword.get(opts, :capability_profile, :rich_terminal),
          degradation_strategy: Keyword.get(opts, :degradation_strategy, :inline_overlay)
        }),
      state:
        Builder.state(opts, %{
          open: Keyword.get(opts, :open, true),
          phase: Keyword.get(opts, :phase, :active)
        }),
      slots: [:base, :overlay],
      slot_children: %{base: [base], overlay: overlays},
      events: Builder.events(close: opts[:on_close], focus: opts[:on_focus]),
      styles: Builder.styles(opts)
    )
  end

  @spec popover(String.t() | atom(), Widget.t(), Widget.t(), keyword()) :: Widget.t()
  def popover(id, anchor, content, opts \\ []) do
    Widget.new(:popover,
      id: id,
      family: :layout,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :popover), %{
          overlay_role: :popover,
          degradation_strategy: Keyword.get(opts, :degradation_strategy, :inline_details)
        }),
      state: Builder.state(opts, %{open: Keyword.get(opts, :open, true)}),
      slots: [:anchor, :content],
      slot_children: %{anchor: [anchor], content: [content]},
      events: Builder.events(close: opts[:on_close]),
      styles: Builder.styles(opts)
    )
  end

  @spec context_menu(String.t() | atom(), Widget.t(), [keyword() | map()], keyword()) ::
          Widget.t()
  def context_menu(id, target, items, opts \\ []) do
    Widget.new(:context_menu,
      id: id,
      family: :layout,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :context_menu), %{
          overlay_role: :context_menu,
          degradation_strategy: Keyword.get(opts, :degradation_strategy, :inline_menu_selection)
        }),
      state:
        Builder.state(opts, %{
          open: Keyword.get(opts, :open, true),
          current: Keyword.get(opts, :current)
        }),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :binding)}),
      slots: [:target],
      slot_children: %{target: [target]},
      attributes: %{items: Builder.normalize_items(items)},
      events: Builder.events(select: opts[:on_select], close: opts[:on_close]),
      styles: Builder.styles(opts)
    )
  end

  @spec absolute(String.t() | atom(), Widget.t(), keyword()) :: Widget.t()
  def absolute(id, content, opts \\ []) do
    Widget.new(:absolute,
      id: id,
      family: :layout,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :absolute), %{
          overlay_role: :absolute,
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
