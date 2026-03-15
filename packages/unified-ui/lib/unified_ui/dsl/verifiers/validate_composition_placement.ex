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

    case validate_nodes(nodes) do
      :ok ->
        :ok

      {:error, path, message} ->
        {:error, %Spark.Error.DslError{module: module, path: path, message: message}}
    end
  end

  defp validate_nodes(nodes) do
    Enum.reduce_while(nodes, :ok, fn node, _acc ->
      case validate_node(node) do
        :ok -> {:cont, :ok}
        {:error, _path, _message} = error -> {:halt, error}
      end
    end)
  end

  defp validate_node(%Node{kind: :field, id: id, children: children}) do
    cond do
      length(children) != 1 ->
        {:error, [:composition, :field, id],
         "field #{inspect(id)} must contain exactly one input child"}

      List.first(children).family != :input ->
        {:error, [:composition, :field, id],
         "field #{inspect(id)} may only contain input controls"}

      true ->
        validate_nodes(children)
    end
  end

  defp validate_node(%Node{kind: kind, id: id, children: children}) when kind in @leaf_kinds do
    if children == [] do
      :ok
    else
      {:error, [:composition, kind, id],
       "#{kind} #{inspect(id)} is a leaf node and cannot declare nested children"}
    end
  end

  defp validate_node(%Node{kind: kind, children: children}) when kind in @layout_kinds do
    validate_nodes(children)
  end

  defp validate_node(%Node{kind: kind, children: children}) when kind in @container_kinds do
    validate_nodes(children)
  end

  defp validate_node(%Node{children: children}) do
    validate_nodes(children)
  end
end
