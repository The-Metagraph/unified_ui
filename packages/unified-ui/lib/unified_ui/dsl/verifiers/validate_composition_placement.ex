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
    identifiers = MapSet.new(Enum.map(nodes, & &1.id))

    case validate_nodes(nodes, identifiers) do
      :ok ->
        :ok

      {:error, path, message} ->
        {:error, %Spark.Error.DslError{module: module, path: path, message: message}}
    end
  end

  defp validate_nodes(nodes, identifiers) do
    Enum.reduce_while(nodes, :ok, fn node, _acc ->
      case validate_node(node, identifiers) do
        :ok -> {:cont, :ok}
        {:error, _path, _message} = error -> {:halt, error}
      end
    end)
  end

  defp validate_node(%Node{kind: :field, id: id, children: children}, identifiers) do
    cond do
      length(children) != 1 ->
        {:error, [:composition, :field, id],
         "field #{inspect(id)} must contain exactly one input child"}

      List.first(children).family != :input ->
        {:error, [:composition, :field, id],
         "field #{inspect(id)} may only contain input controls"}

      true ->
        validate_nodes(children, identifiers)
    end
  end

  defp validate_node(%Node{kind: :dialog, id: id, content_ref: content_ref}, identifiers) do
    cond do
      is_nil(content_ref) ->
        {:error, [:composition, :dialog, id],
         "dialog #{inspect(id)} must reference dialog content through content_ref"}

      content_ref == id ->
        {:error, [:composition, :dialog, id],
         "dialog #{inspect(id)} may not reference itself as content_ref"}

      not MapSet.member?(identifiers, content_ref) ->
        {:error, [:composition, :dialog, id],
         "dialog #{inspect(id)} references missing content_ref #{inspect(content_ref)}"}

      true ->
        :ok
    end
  end

  defp validate_node(%Node{kind: kind, id: id, target_ref: target_ref}, identifiers)
       when kind in [:context_menu, :scroll_bar] do
    cond do
      is_nil(target_ref) ->
        {:error, [:composition, kind, id],
         "#{kind} #{inspect(id)} must reference an existing authored node through target_ref"}

      target_ref == id ->
        {:error, [:composition, kind, id],
         "#{kind} #{inspect(id)} may not reference itself through target_ref"}

      not MapSet.member?(identifiers, target_ref) ->
        {:error, [:composition, kind, id],
         "#{kind} #{inspect(id)} references missing target_ref #{inspect(target_ref)}"}

      true ->
        :ok
    end
  end

  defp validate_node(
         %Node{kind: :split_pane, id: id, primary_ref: primary_ref, secondary_ref: secondary_ref},
         identifiers
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

      not MapSet.member?(identifiers, primary_ref) ->
        {:error, [:composition, :split_pane, id],
         "split_pane #{inspect(id)} references missing primary_ref #{inspect(primary_ref)}"}

      not MapSet.member?(identifiers, secondary_ref) ->
        {:error, [:composition, :split_pane, id],
         "split_pane #{inspect(id)} references missing secondary_ref #{inspect(secondary_ref)}"}

      true ->
        :ok
    end
  end

  defp validate_node(%Node{kind: kind, id: id, children: children}, _identifiers)
       when kind in @leaf_kinds do
    if children == [] do
      :ok
    else
      {:error, [:composition, kind, id],
       "#{kind} #{inspect(id)} is a leaf node and cannot declare nested children"}
    end
  end

  defp validate_node(%Node{kind: kind, children: children}, identifiers)
       when kind in @layout_kinds do
    validate_nodes(children, identifiers)
  end

  defp validate_node(%Node{kind: kind, children: children}, identifiers)
       when kind in @container_kinds do
    validate_nodes(children, identifiers)
  end

  defp validate_node(%Node{children: children}, identifiers) do
    validate_nodes(children, identifiers)
  end
end
