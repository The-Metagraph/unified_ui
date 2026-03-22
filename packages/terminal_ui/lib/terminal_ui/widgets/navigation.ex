defmodule TerminalUi.Widgets.Navigation do
  @moduledoc """
  Foundational navigation surfaces for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [:tabs, :menu, :breadcrumbs, :list]
  end

  @spec tabs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def tabs(id, items, opts \\ []) do
    Widget.new(:tabs,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :tabs], opts)
        ),
      state: Builder.state(opts, %{current: Keyword.get(opts, :current)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :binding)}),
      attributes: %{items: Builder.normalize_items(items)},
      events: Builder.events(navigation: opts[:on_navigate], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  @spec menu(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    Widget.new(:menu,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :menu], opts)
        ),
      state: Builder.state(opts, %{current: Keyword.get(opts, :current)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :binding)}),
      attributes: %{items: Builder.normalize_items(items)},
      events: Builder.events(navigation: opts[:on_navigate], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  @spec breadcrumbs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def breadcrumbs(id, items, opts \\ []) do
    Widget.new(:breadcrumbs,
      id: id,
      metadata: Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :breadcrumbs)),
      state: Builder.state(opts, %{current: Keyword.get(opts, :current)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :binding)}),
      attributes: %{items: Builder.normalize_items(items)},
      events: Builder.events(activate: opts[:on_follow]),
      styles: Builder.styles(opts)
    )
  end

  @spec list(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def list(id, items, opts \\ []) do
    Widget.new(:list,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :list], opts)
        ),
      state: Builder.state(opts, %{current: Keyword.get(opts, :current)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :binding)}),
      attributes: %{items: Builder.normalize_items(items)},
      events: Builder.events(navigation: opts[:on_navigate], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
