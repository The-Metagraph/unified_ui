defmodule DesktopUi.Widgets.Data do
  @moduledoc """
  Advanced data and document-oriented widgets for direct-native `desktop_ui`.
  """

  alias DesktopUi.Widget

  @spec kinds() :: [atom()]
  def kinds do
    [:inspector, :markdown_viewer, :table, :tree_view]
  end

  @spec table(String.t() | atom(), [map() | keyword()], [map() | keyword()], keyword()) ::
          Widget.t()
  def table(id, columns, rows, opts \\ []) do
    Widget.new(:table,
      id: id,
      metadata:
        metadata(opts,
          focusable: true,
          role: :table,
          selection_mode: Keyword.get(opts, :selection_mode, :single),
          sort_key: Keyword.get(opts, :sort_key)
        ),
      state:
        state(opts,
          loading: Keyword.get(opts, :loading, false),
          selected: Keyword.get(opts, :selected)
        ),
      bindings:
        bindings(
          selection: Keyword.get(opts, :selection_binding, Keyword.get(opts, :binding)),
          filters: Keyword.get(opts, :filters_binding)
        ),
      attributes: %{
        columns: normalize_items(columns),
        rows: normalize_items(rows),
        dense: Keyword.get(opts, :dense, false),
        selection_mode: Keyword.get(opts, :selection_mode, :single),
        sorting: %{
          key: Keyword.get(opts, :sort_key),
          direction: Keyword.get(opts, :sort_direction)
        }
      },
      events:
        events(
          selection: Keyword.get(opts, :on_select),
          sort: Keyword.get(opts, :on_sort),
          filter: Keyword.get(opts, :on_filter),
          paginate: Keyword.get(opts, :on_paginate)
        ),
      styles: styles(opts)
    )
  end

  @spec tree_view(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def tree_view(id, nodes, opts \\ []) do
    Widget.new(:tree_view,
      id: id,
      metadata:
        metadata(opts,
          focusable: true,
          role: :tree_view,
          selection_mode: Keyword.get(opts, :selection_mode, :single)
        ),
      state:
        state(opts,
          expanded: Keyword.get(opts, :expanded, []),
          selected: Keyword.get(opts, :selected)
        ),
      bindings:
        bindings(
          selection: Keyword.get(opts, :selection_binding, Keyword.get(opts, :binding)),
          expansion: Keyword.get(opts, :expansion_binding)
        ),
      attributes: %{nodes: normalize_nodes(nodes), query: Keyword.get(opts, :query)},
      events:
        events(
          selection: Keyword.get(opts, :on_select),
          expand: Keyword.get(opts, :on_expand),
          filter: Keyword.get(opts, :on_filter)
        ),
      styles: styles(opts)
    )
  end

  @spec inspector(String.t() | atom(), map() | keyword(), keyword()) :: Widget.t()
  def inspector(id, subject, opts \\ []) do
    Widget.new(:inspector,
      id: id,
      metadata: metadata(opts, focusable: true, role: :inspector),
      state: state(opts, expanded: Keyword.get(opts, :expanded, true)),
      attributes: %{
        subject: normalize_item(subject),
        sections: normalize_items(Keyword.get(opts, :sections, []))
      },
      events:
        events(expand: Keyword.get(opts, :on_expand), selection: Keyword.get(opts, :on_select)),
      styles: styles(opts)
    )
  end

  @spec markdown_viewer(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def markdown_viewer(id, markdown, opts \\ []) do
    Widget.new(:markdown_viewer,
      id: id,
      metadata:
        metadata(opts, focusable: true, role: :document, selection_mode: :document_navigation),
      state: state(opts),
      attributes: %{
        source: markdown,
        anchors: normalize_items(Keyword.get(opts, :anchors, [])),
        mode: Keyword.get(opts, :mode, :rendered)
      },
      events: events(navigation: Keyword.get(opts, :on_navigate)),
      styles: styles(opts)
    )
  end

  defp metadata(opts, defaults) do
    defaults
    |> Keyword.merge(Keyword.get(opts, :metadata, []))
    |> Map.new()
  end

  defp state(opts, defaults \\ []) do
    defaults
    |> Keyword.merge(disabled: Keyword.get(opts, :disabled, false), focused: false)
    |> Map.new()
  end

  defp bindings(entries) do
    entries
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end

  defp events(entries) do
    entries
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end

  defp styles(opts), do: Map.new(Keyword.get(opts, :styles, []))

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

  defp normalize_items(items), do: Enum.map(List.wrap(items), &normalize_item/1)
  defp normalize_item(item) when is_list(item), do: Enum.into(item, %{})
  defp normalize_item(item) when is_map(item), do: Map.new(item)
end
