defmodule UnifiedUi.Dsl.Verifiers.ValidateCompositionPlacement do
  @moduledoc false

  use Spark.Dsl.Verifier

  alias UnifiedUi.Dsl.{Node, Placement}

  @leaf_kinds Placement.leaf_kinds()
  @layout_kinds Placement.layout_kinds()
  @container_kinds Placement.container_kinds()

  @spec verify(map()) :: :ok | {:error, Spark.Error.DslError.t()}
  def verify(dsl) do
    module = Spark.Dsl.Verifier.get_persisted(dsl, :module)
    nodes = Spark.Dsl.Verifier.get_entities(dsl, [:composition])
    node_index = index_nodes(nodes)

    case validate_nodes(nodes, node_index) do
      :ok ->
        :ok

      {:error, path, message} ->
        {:error, %Spark.Error.DslError{module: module, path: path, message: message}}
    end
  end

  defp validate_nodes(nodes, node_index, row_scope \\ nil) do
    Enum.reduce_while(nodes, :ok, fn node, _acc ->
      with :ok <- validate_node_row_scope(node, row_scope),
           :ok <- validate_node(node, node_index, row_scope) do
        {:cont, :ok}
      else
        {:error, _path, _message} = error -> {:halt, error}
      end
    end)
  end

  defp index_nodes(nodes) do
    Enum.reduce(nodes, %{}, fn node, acc ->
      acc
      |> Map.put(node.id, node)
      |> Map.merge(index_nodes(node.children || []))
    end)
  end

  defp validate_node(
         %Node{
           kind: :repeated_collection,
           id: id,
           collection_source: collection_source,
           item_alias: item_alias,
           index_alias: index_alias,
           key_path: key_path,
           children: children
         },
         node_index,
         row_scope
       ) do
    cond do
      not is_nil(row_scope) ->
        {:error, [:composition, :repeated_collection, id],
         "repeated_collection #{inspect(id)} may not be nested inside another repeated_collection"}

      invalid_collection_source?(collection_source) ->
        {:error, [:composition, :repeated_collection, id],
         "repeated_collection #{inspect(id)} must use a portable collection_source and must not use Ash resource relationships or renderer-local iteration callbacks"}

      not valid_alias?(item_alias) ->
        {:error, [:composition, :repeated_collection, id],
         "repeated_collection #{inspect(id)} must declare item_alias as an atom"}

      not valid_alias?(index_alias) ->
        {:error, [:composition, :repeated_collection, id],
         "repeated_collection #{inspect(id)} must declare index_alias as an atom"}

      item_alias == index_alias ->
        {:error, [:composition, :repeated_collection, id],
         "repeated_collection #{inspect(id)} must use distinct item_alias and index_alias values"}

      not valid_key_path?(key_path) ->
        {:error, [:composition, :repeated_collection, id],
         "repeated_collection #{inspect(id)} must declare a non-empty atom key_path for stable row identity"}

      length(children) != 1 ->
        {:error, [:composition, :repeated_collection, id],
         "repeated_collection #{inspect(id)} must declare exactly one child template"}

      invalid_template_child?(List.first(children)) ->
        {:error, [:composition, :repeated_collection, id],
         "repeated_collection #{inspect(id)} child template must be a widget or layout and may not be a layer, display, canvas, or nested collection"}

      true ->
        validate_nodes(children, node_index, %{item_alias: item_alias, index_alias: index_alias})
    end
  end

  defp validate_node(%Node{kind: :field, id: id, children: children}, node_index, row_scope) do
    cond do
      length(children) != 1 ->
        {:error, [:composition, :field, id],
         "field #{inspect(id)} must contain exactly one input child"}

      List.first(children).family != :input ->
        {:error, [:composition, :field, id],
         "field #{inspect(id)} may only contain input controls"}

      true ->
        validate_nodes(children, node_index, row_scope)
    end
  end

  defp validate_node(
         %Node{kind: :dialog, id: id, content_ref: content_ref, trigger_ref: trigger_ref},
         node_index,
         _row_scope
       ) do
    with :ok <- validate_required_ref(:dialog, id, :content_ref, content_ref, node_index),
         :ok <- validate_non_overlay_target(:dialog, id, :content_ref, content_ref, node_index),
         :ok <- validate_optional_ref(:dialog, id, :trigger_ref, trigger_ref, node_index) do
      :ok
    end
  end

  defp validate_node(
         %Node{kind: :context_menu, id: id, target_ref: target_ref, trigger_ref: trigger_ref},
         node_index,
         _row_scope
       ) do
    with :ok <- validate_required_ref(:context_menu, id, :target_ref, target_ref, node_index),
         :ok <- validate_optional_ref(:context_menu, id, :trigger_ref, trigger_ref, node_index) do
      :ok
    end
  end

  defp validate_node(
         %Node{kind: :alert_dialog, id: id, trigger_ref: trigger_ref},
         node_index,
         _row_scope
       ) do
    validate_optional_ref(:alert_dialog, id, :trigger_ref, trigger_ref, node_index)
  end

  defp validate_node(
         %Node{kind: :toast, id: id, trigger_ref: trigger_ref},
         node_index,
         _row_scope
       ) do
    validate_optional_ref(:toast, id, :trigger_ref, trigger_ref, node_index)
  end

  defp validate_node(
         %Node{kind: :scroll_bar, id: id, target_ref: target_ref},
         node_index,
         _row_scope
       ) do
    with :ok <- validate_required_ref(:scroll_bar, id, :target_ref, target_ref, node_index),
         :ok <-
           validate_allowed_target_family(:scroll_bar, id, :target_ref, target_ref, node_index, [
             :layout,
             :display
           ]) do
      :ok
    end
  end

  defp validate_node(
         %Node{kind: :split_pane, id: id, primary_ref: primary_ref, secondary_ref: secondary_ref},
         node_index,
         _row_scope
       ) do
    cond do
      is_nil(primary_ref) or is_nil(secondary_ref) ->
        {:error, [:composition, :split_pane, id],
         "split_pane #{inspect(id)} must declare both primary_ref and secondary_ref"}

      primary_ref == secondary_ref ->
        {:error, [:composition, :split_pane, id],
         "split_pane #{inspect(id)} must reference two distinct authored nodes"}

      primary_ref == id or secondary_ref == id ->
        {:error, [:composition, :split_pane, id],
         "split_pane #{inspect(id)} may not reference itself as a pane target"}

      not Map.has_key?(node_index, primary_ref) ->
        {:error, [:composition, :split_pane, id],
         "split_pane #{inspect(id)} references missing primary_ref #{inspect(primary_ref)}"}

      not Map.has_key?(node_index, secondary_ref) ->
        {:error, [:composition, :split_pane, id],
         "split_pane #{inspect(id)} references missing secondary_ref #{inspect(secondary_ref)}"}

      referenced_family(node_index, primary_ref) == :overlay or
          referenced_family(node_index, secondary_ref) == :overlay ->
        {:error, [:composition, :split_pane, id],
         "split_pane #{inspect(id)} may not use overlay nodes as pane targets"}

      true ->
        :ok
    end
  end

  defp validate_node(%Node{kind: kind, id: id, content_ref: content_ref}, node_index, _row_scope)
       when kind in [:viewport, :scroll_region] do
    with :ok <- validate_required_ref(kind, id, :content_ref, content_ref, node_index),
         :ok <- validate_non_overlay_target(kind, id, :content_ref, content_ref, node_index) do
      :ok
    end
  end

  defp validate_node(
         %Node{kind: :overlay, id: id, base_ref: base_ref, layer_refs: layer_refs},
         node_index,
         _row_scope
       ) do
    with :ok <- validate_required_ref(:overlay, id, :base_ref, base_ref, node_index),
         :ok <- validate_non_overlay_target(:overlay, id, :base_ref, base_ref, node_index),
         :ok <- validate_layer_refs(id, base_ref, layer_refs, node_index) do
      :ok
    end
  end

  defp validate_node(
         %Node{kind: :absolute, id: id, content_ref: content_ref, target_ref: target_ref},
         node_index,
         _row_scope
       ) do
    cond do
      content_ref == target_ref ->
        {:error, [:composition, :absolute, id],
         "absolute #{inspect(id)} must reference distinct content_ref and target_ref nodes"}

      true ->
        with :ok <- validate_required_ref(:absolute, id, :content_ref, content_ref, node_index),
             :ok <- validate_required_ref(:absolute, id, :target_ref, target_ref, node_index),
             :ok <-
               validate_non_overlay_target(:absolute, id, :content_ref, content_ref, node_index),
             :ok <-
               validate_non_overlay_target(:absolute, id, :target_ref, target_ref, node_index) do
          :ok
        end
    end
  end

  defp validate_node(
         %Node{kind: :canvas, id: id, operations: operations},
         _node_index,
         _row_scope
       ) do
    validate_canvas_operations(id, operations)
  end

  defp validate_node(%Node{kind: kind, id: id, children: children}, _node_index, _row_scope)
       when kind in @leaf_kinds do
    if children == [] do
      :ok
    else
      {:error, [:composition, kind, id],
       "#{kind} #{inspect(id)} is a leaf node and cannot declare nested children"}
    end
  end

  defp validate_node(%Node{kind: kind, children: children}, node_index, row_scope)
       when kind in @layout_kinds do
    validate_nodes(children, node_index, row_scope)
  end

  defp validate_node(%Node{kind: kind, children: children}, node_index, row_scope)
       when kind in @container_kinds do
    validate_nodes(children, node_index, row_scope)
  end

  defp validate_node(%Node{children: children}, node_index, row_scope) do
    validate_nodes(children, node_index, row_scope)
  end

  defp validate_node_row_scope(%Node{} = node, row_scope) do
    node
    |> node_own_values()
    |> collect_row_scope_refs()
    |> validate_row_scope_refs(node, row_scope)
  end

  defp node_own_values(%Node{} = node) do
    node
    |> Map.from_struct()
    |> Map.drop([:__identifier__, :children])
    |> Map.values()
  end

  defp validate_row_scope_refs([], _node, _row_scope), do: :ok

  defp validate_row_scope_refs(_refs, %Node{kind: kind, id: id}, nil) do
    {:error, [:composition, kind, id],
     "#{kind} #{inspect(id)} uses row-scope references outside a repeated_collection template"}
  end

  defp validate_row_scope_refs(refs, %Node{kind: kind, id: id}, row_scope) do
    allowed_aliases = [row_scope.item_alias, row_scope.index_alias]

    Enum.reduce_while(refs, :ok, fn ref, _acc ->
      alias_name = row_scope_alias(ref)

      if is_nil(alias_name) or alias_name in allowed_aliases do
        {:cont, :ok}
      else
        {:halt,
         {:error, [:composition, kind, id],
          "#{kind} #{inspect(id)} references unavailable row alias #{inspect(alias_name)}"}}
      end
    end)
  end

  defp collect_row_scope_refs(values) when is_list(values) do
    Enum.flat_map(values, &collect_row_scope_refs/1)
  end

  defp collect_row_scope_refs(%{kind: kind} = value)
       when kind in [:row_value, :row_index, :row_key] do
    [value]
  end

  defp collect_row_scope_refs(%{"kind" => kind} = value)
       when kind in [:row_value, :row_index, :row_key] do
    [value]
  end

  defp collect_row_scope_refs(%_struct{}), do: []

  defp collect_row_scope_refs(values) when is_map(values) do
    values
    |> Map.values()
    |> collect_row_scope_refs()
  end

  defp collect_row_scope_refs(_other), do: []

  defp row_scope_alias(ref) when is_map(ref) do
    Map.get(ref, :alias) || Map.get(ref, "alias")
  end

  defp invalid_collection_source?(nil), do: true
  defp invalid_collection_source?(source) when is_function(source), do: true

  defp invalid_collection_source?(source) when is_atom(source) do
    source in [:ash_resource, :ash_relationship, :relationship, :resource]
  end

  defp invalid_collection_source?(source) when is_binary(source) do
    source
    |> String.downcase()
    |> String.contains?(["ash", "relationship", "resource"])
  end

  defp invalid_collection_source?(source) when is_list(source) do
    Enum.any?(source, fn
      {key, value} -> invalid_collection_source_key?(key) or invalid_collection_source?(value)
      value -> invalid_collection_source?(value)
    end)
  end

  defp invalid_collection_source?(source) when is_map(source) do
    Enum.any?(source, fn {key, value} ->
      invalid_collection_source_key?(key) or invalid_collection_source?(value)
    end)
  end

  defp invalid_collection_source?(_source), do: false

  defp invalid_collection_source_key?(key)
       when key in [
              :ash,
              :ash_resource,
              :ash_relationship,
              :resource,
              :relationship,
              :relationships,
              :for_each,
              :render,
              :render_item,
              :callback,
              :component
            ],
       do: true

  defp invalid_collection_source_key?(key) when is_binary(key) do
    String.downcase(key) in [
      "ash",
      "ash_resource",
      "ash_relationship",
      "resource",
      "relationship",
      "relationships",
      "for_each",
      "render",
      "render_item",
      "callback",
      "component"
    ]
  end

  defp invalid_collection_source_key?(_key), do: false

  defp valid_alias?(alias_name), do: is_atom(alias_name) and not is_nil(alias_name)

  defp valid_key_path?(key_path) do
    is_list(key_path) and key_path != [] and Enum.all?(key_path, &is_atom/1)
  end

  defp invalid_template_child?(nil), do: true

  defp invalid_template_child?(%Node{kind: :repeated_collection}), do: true

  defp invalid_template_child?(%Node{family: family, children: children}) do
    family in [:collection, :overlay, :display, :canvas] or
      Enum.any?(children || [], &invalid_template_child?/1)
  end

  defp validate_required_ref(kind, id, field, ref, node_index) do
    cond do
      is_nil(ref) ->
        {:error, [:composition, kind, id],
         "#{kind} #{inspect(id)} must reference an existing authored node through #{field}"}

      ref == id ->
        {:error, [:composition, kind, id],
         "#{kind} #{inspect(id)} may not reference itself through #{field}"}

      not Map.has_key?(node_index, ref) ->
        {:error, [:composition, kind, id],
         "#{kind} #{inspect(id)} references missing #{field} #{inspect(ref)}"}

      true ->
        :ok
    end
  end

  defp validate_optional_ref(_kind, _id, _field, nil, _node_index), do: :ok

  defp validate_optional_ref(kind, id, field, ref, node_index) do
    validate_required_ref(kind, id, field, ref, node_index)
  end

  defp validate_non_overlay_target(kind, id, field, ref, node_index) do
    family = referenced_family(node_index, ref)

    if family in [:overlay, :display] do
      {:error, [:composition, kind, id],
       "#{kind} #{inspect(id)} may not target #{family} nodes through #{field}"}
    else
      :ok
    end
  end

  defp validate_allowed_target_family(kind, id, field, ref, node_index, allowed_families) do
    family = referenced_family(node_index, ref)

    if family in allowed_families do
      :ok
    else
      {:error, [:composition, kind, id],
       "#{kind} #{inspect(id)} must target #{inspect(allowed_families)} nodes through #{field}"}
    end
  end

  defp validate_layer_refs(id, base_ref, layer_refs, node_index) do
    cond do
      not is_list(layer_refs) or layer_refs == [] ->
        {:error, [:composition, :overlay, id],
         "overlay #{inspect(id)} must declare at least one layer_ref"}

      Enum.member?(layer_refs, id) ->
        {:error, [:composition, :overlay, id],
         "overlay #{inspect(id)} may not reference itself in layer_refs"}

      Enum.member?(layer_refs, base_ref) ->
        {:error, [:composition, :overlay, id],
         "overlay #{inspect(id)} may not reuse base_ref #{inspect(base_ref)} in layer_refs"}

      true ->
        Enum.reduce_while(layer_refs, :ok, fn ref, _acc ->
          cond do
            not Map.has_key?(node_index, ref) ->
              {:halt,
               {:error, [:composition, :overlay, id],
                "overlay #{inspect(id)} references missing layer_ref #{inspect(ref)}"}}

            referenced_family(node_index, ref) != :overlay ->
              {:halt,
               {:error, [:composition, :overlay, id],
                "overlay #{inspect(id)} may only reference overlay nodes in layer_refs"}}

            true ->
              {:cont, :ok}
          end
        end)
    end
  end

  defp validate_canvas_operations(id, operations) do
    cond do
      not is_list(operations) or operations == [] ->
        {:error, [:composition, :canvas, id],
         "canvas #{inspect(id)} must declare at least one drawing operation"}

      true ->
        Enum.reduce_while(operations, :ok, fn operation, _acc ->
          operation = normalize_operation(operation)

          cond do
            Map.get(operation, :kind) not in [:cell, :fragment, :line, :rect, :text] ->
              {:halt,
               {:error, [:composition, :canvas, id],
                "canvas #{inspect(id)} operations must declare a supported kind"}}

            not valid_canvas_position?(Map.get(operation, :position)) ->
              {:halt,
               {:error, [:composition, :canvas, id],
                "canvas #{inspect(id)} operations must declare a {x, y} position"}}

            true ->
              {:cont, :ok}
          end
        end)
    end
  end

  defp normalize_operation(operation) when is_map(operation), do: Map.new(operation)
  defp normalize_operation(operation) when is_list(operation), do: Enum.into(operation, %{})

  defp valid_canvas_position?({x, y}) when is_integer(x) and is_integer(y), do: true
  defp valid_canvas_position?(_position), do: false

  defp referenced_family(node_index, ref) do
    node_index
    |> Map.fetch!(ref)
    |> Map.get(:family)
  end
end
