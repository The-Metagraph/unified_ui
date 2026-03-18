defmodule WebUi.Frontend.Realization do
  @moduledoc """
  Frontend-side realization of server-authored render trees into browser-facing
  node descriptions.
  """

  @spec realize([map()], map()) :: [map()]
  def realize(render_tree, local_state \\ %{})
      when is_list(render_tree) and is_map(local_state) do
    Enum.map(render_tree, &realize_node(&1, local_state))
  end

  defp realize_node(node, local_state) do
    %{
      id: node.id,
      family: node.family,
      kind: node.kind,
      tag: node.dom.tag,
      role: node.dom.role,
      attrs: node.dom.attributes,
      props: node.props,
      semantics: node.semantics,
      browser: %{
        interactive?: node.interactions.interactive?,
        focusable?: node.interactions.focusable?,
        editable?: node.interactions.editable?,
        focused?: local_state[:focused_widget] == node.id,
        editing?: editing?(local_state, node.id, node.state),
        selection: selection_state(local_state, node),
        sorting: sorting_state(local_state, node),
        filters: filter_state(local_state, node),
        pagination: pagination_state(local_state, node),
        viewport: viewport_state(local_state, node),
        split: split_state(local_state, node),
        layer: layer_state(local_state, node),
        metrics: Map.get(node.semantics, :metrics, %{})
      },
      slots:
        Enum.map(node.slots, fn slot ->
          %{
            name: slot.name,
            children: Enum.map(slot.children, &realize_node(&1, local_state))
          }
        end)
    }
  end

  defp editing?(local_state, id, state) do
    editing_widgets = Map.get(local_state, :editing_widgets, [])

    id in List.wrap(editing_widgets) or Map.get(state, :editing?, false)
  end

  defp selection_state(local_state, node) do
    selected_items = Map.get(local_state, :selected_items, %{})

    %{
      mode: Map.get(node.semantics, :selection_mode),
      selected_ids: Map.get(selected_items, node.id, selected_ids(node))
    }
  end

  defp sorting_state(local_state, node) do
    table_sort = Map.get(local_state, :table_sort, %{})
    Map.get(table_sort, node.id, Map.get(node.semantics, :sorting))
  end

  defp filter_state(local_state, node) do
    filters = Map.get(local_state, :filters, %{})
    Map.get(filters, node.id, Map.get(node.semantics, :filters, []))
  end

  defp pagination_state(local_state, node) do
    pages = Map.get(local_state, :pages, %{})
    Map.get(pages, node.id, Map.get(node.semantics, :pagination))
  end

  defp viewport_state(local_state, node) do
    case Map.get(node.semantics, :display) do
      %{offset: offset} = display ->
        offsets = Map.get(local_state, :viewport_offsets, %{})

        display
        |> Map.put(:offset, Map.get(offsets, node.id, offset))
        |> Map.put(:scrolled?, Map.get(node.state, :scrolled?, false))

      %{position: position} = display ->
        positions = Map.get(local_state, :scroll_positions, %{})
        Map.put(display, :position, Map.get(positions, node.id, position))

      _other ->
        nil
    end
  end

  defp split_state(local_state, node) do
    case Map.get(node.semantics, :display) do
      %{ratio: ratio} = display ->
        split_ratios = Map.get(local_state, :split_ratios, %{})
        Map.put(display, :ratio, Map.get(split_ratios, node.id, ratio))

      _other ->
        nil
    end
  end

  defp layer_state(local_state, node) do
    case Map.get(node.semantics, :layer) do
      nil ->
        nil

      layer ->
        open_layers = Map.get(local_state, :open_layers, %{})
        dismissed_layers = Map.get(local_state, :dismissed_layers, [])

        layer
        |> Map.put(:open?, Map.get(open_layers, node.id, Map.get(node.state, :open?, true)))
        |> Map.put(:dismissed?, node.id in List.wrap(dismissed_layers))
        |> Map.put(
          :focus_scope,
          get_in(local_state, [:focus_scopes, node.id]) || Map.get(layer, :focus_scope)
        )
    end
  end

  defp selected_ids(%{kind: :table, props: props}) do
    props
    |> Map.get(:rows, [])
    |> Enum.filter(&Map.get(&1, :selected?, false))
    |> Enum.map(&Map.get(&1, :id))
  end

  defp selected_ids(%{kind: kind, props: props})
       when kind in [:tree_view, :supervision_tree_viewer] do
    props
    |> Map.get(:nodes, [])
    |> flatten_selected_nodes()
  end

  defp selected_ids(_node), do: []

  defp flatten_selected_nodes(nodes) when is_list(nodes) do
    Enum.flat_map(nodes, fn node ->
      selected = if Map.get(node, :selected?, false), do: [Map.get(node, :id)], else: []
      selected ++ flatten_selected_nodes(Map.get(node, :children, []))
    end)
  end

  defp flatten_selected_nodes(_other), do: []
end
