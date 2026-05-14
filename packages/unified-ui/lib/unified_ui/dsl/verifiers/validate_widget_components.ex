defmodule UnifiedUi.Dsl.Verifiers.ValidateWidgetComponents do
  @moduledoc false

  use Spark.Dsl.Verifier

  alias Spark.Dsl.Verifier
  alias UnifiedUi.Dsl.Node

  @heading_segment_types [:text, :emphasis]

  @spec verify(map()) :: :ok | {:error, Spark.Error.DslError.t()}
  def verify(dsl) do
    module = Verifier.get_persisted(dsl, :module)

    dsl
    |> Verifier.get_entities([:composition])
    |> Enum.filter(&match?(%Node{}, &1))
    |> flatten_nodes()
    |> validate_nodes(module)
  end

  defp validate_nodes(nodes, module) do
    Enum.reduce_while(nodes, :ok, fn node, :ok ->
      case validate_node(node) do
        :ok ->
          {:cont, :ok}

        {:error, path, message} ->
          {:halt, {:error, %Spark.Error.DslError{module: module, path: path, message: message}}}
      end
    end)
  end

  @doc false
  @spec validate_node(Node.t()) :: :ok | {:error, [term()], String.t()}
  def validate_node(%Node{kind: :inline_rich_text_heading, id: id, segments: segments}) do
    if valid_heading_segments?(segments) do
      :ok
    else
      {:error, [:composition, :inline_rich_text_heading, id],
       "inline_rich_text_heading #{inspect(id)} segments must be a non-empty list of text or emphasis segment maps with string values"}
    end
  end

  def validate_node(%Node{kind: :kicker, id: id, items: items}) do
    if is_list(items) and Enum.all?(items, &is_binary/1) do
      :ok
    else
      {:error, [:composition, :kicker, id],
       "kicker #{inspect(id)} items must be a list of strings"}
    end
  end

  def validate_node(_node), do: :ok

  defp valid_heading_segments?(segments) when is_list(segments) and segments != [] do
    Enum.all?(segments, &valid_heading_segment?/1)
  end

  defp valid_heading_segments?(_segments), do: false

  defp valid_heading_segment?(segment) when is_map(segment) or is_list(segment) do
    segment = normalize_map(segment)
    Map.get(segment, :type) in @heading_segment_types and is_binary(Map.get(segment, :value))
  end

  defp valid_heading_segment?(_segment), do: false

  defp normalize_map(segment) when is_map(segment) do
    Map.new(segment, fn
      {key, value} when is_binary(key) ->
        {String.to_existing_atom(key), value}

      {key, value} ->
        {key, value}
    end)
  rescue
    ArgumentError -> segment
  end

  defp normalize_map(segment) when is_list(segment), do: Map.new(segment)

  defp flatten_nodes(nodes) do
    Enum.flat_map(nodes, fn %Node{children: children} = node ->
      [node | flatten_nodes(children)]
    end)
  end
end
