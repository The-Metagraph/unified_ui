defmodule TerminalUi.Widgets.Data do
  @moduledoc """
  Advanced data and document-oriented widgets for direct-use `terminal_ui` screens.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [:table, :tree_view, :inspector, :markdown_viewer]
  end

  @spec table(String.t() | atom(), [keyword() | map()], [keyword() | map()], keyword()) ::
          Widget.t()
  def table(id, columns, rows, opts \\ []) do
    Widget.new(:table,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :table], opts),
          %{
            selection_mode: Keyword.get(opts, :selection_mode, :single),
            sort_key: Keyword.get(opts, :sort_key)
          }
        ),
      state:
        Builder.state(opts, %{
          loading: Keyword.get(opts, :loading, false),
          selected: Keyword.get(opts, :selected)
        }),
      bindings:
        Builder.bindings(opts, %{
          filters: Keyword.get(opts, :filters_binding),
          selection: Keyword.get(opts, :selection_binding, Keyword.get(opts, :binding))
        }),
      attributes: %{
        columns: Builder.normalize_items(columns),
        rows: Builder.normalize_items(rows),
        dense: Keyword.get(opts, :dense, false),
        selection_mode: Keyword.get(opts, :selection_mode, :single),
        sorting: %{
          key: Keyword.get(opts, :sort_key),
          direction: Keyword.get(opts, :sort_direction)
        }
      },
      events:
        Builder.events(
          select: opts[:on_select],
          sort: opts[:on_sort],
          filter: opts[:on_filter],
          paginate: opts[:on_paginate]
        ),
      styles: Builder.styles(opts)
    )
  end

  @spec tree_view(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def tree_view(id, nodes, opts \\ []) do
    Widget.new(:tree_view,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :tree_view], opts),
          %{
            selection_mode: Keyword.get(opts, :selection_mode, :single)
          }
        ),
      state:
        Builder.state(opts, %{
          expanded: Keyword.get(opts, :expanded, false),
          selected: Keyword.get(opts, :selected)
        }),
      bindings:
        Builder.bindings(opts, %{
          selection: Keyword.get(opts, :selection_binding, Keyword.get(opts, :binding)),
          filters: Keyword.get(opts, :filters_binding)
        }),
      attributes: %{
        nodes: normalize_nodes(nodes),
        selection_mode: Keyword.get(opts, :selection_mode, :single),
        query: Keyword.get(opts, :query)
      },
      events:
        Builder.events(
          select: opts[:on_select],
          expand: opts[:on_expand],
          filter: opts[:on_filter]
        ),
      styles: Builder.styles(opts)
    )
  end

  @spec inspector(String.t() | atom(), map() | keyword(), keyword()) :: Widget.t()
  def inspector(id, subject, opts \\ []) do
    Widget.new(:inspector,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :inspector], opts)
        ),
      state: Builder.state(opts, %{expanded: Keyword.get(opts, :expanded, true)}),
      attributes: %{
        subject: normalize_item(subject),
        sections: Builder.normalize_items(Keyword.get(opts, :sections, []))
      },
      events: Builder.events(expand: opts[:on_expand], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  @spec markdown_viewer(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def markdown_viewer(id, markdown, opts \\ []) do
    Widget.new(:markdown_viewer,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :document], opts),
          %{
            capability_profile: Keyword.get(opts, :capability_profile, :rich_terminal)
          }
        ),
      state: Builder.state(opts, %{}),
      attributes: %{
        source: markdown,
        anchors: Builder.normalize_items(Keyword.get(opts, :anchors, [])),
        mode: Keyword.get(opts, :mode, :rendered)
      },
      events: Builder.events(navigation: opts[:on_navigate]),
      styles: Builder.styles(opts)
    )
  end

  defp normalize_nodes(nodes) do
    Enum.map(nodes, fn node ->
      node = normalize_item(node)
      children = node |> Map.get(:children, []) |> List.wrap() |> normalize_nodes()

      node
      |> Map.delete(:children)
      |> then(fn base ->
        if children == [], do: base, else: Map.put(base, :children, children)
      end)
    end)
  end

  defp normalize_item(item) when is_list(item), do: Enum.into(item, %{})
  defp normalize_item(item) when is_map(item), do: Map.new(item)

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
