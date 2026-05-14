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

  def validate_node(%Node{kind: :segmented_button_group, id: id, options: options}) do
    if valid_options?(options) do
      :ok
    else
      {:error, [:composition, :segmented_button_group, id],
       "segmented_button_group #{inspect(id)} options must be a non-empty list of {value, label} tuples or maps with value and label"}
    end
  end

  def validate_node(%Node{kind: :runtime_form_shell, id: id, fields: fields}) do
    if valid_form_fields?(fields) do
      :ok
    else
      {:error, [:composition, :runtime_form_shell, id],
       "runtime_form_shell #{inspect(id)} fields must be a non-empty list of maps with name and type"}
    end
  end

  def validate_node(%Node{kind: :chat_composer, id: id, rows: rows, send_intent: send_intent}) do
    cond do
      not is_atom(send_intent) ->
        {:error, [:composition, :chat_composer, id],
         "chat_composer #{inspect(id)} send_intent must be an atom"}

      not is_integer(rows) or rows < 1 ->
        {:error, [:composition, :chat_composer, id],
         "chat_composer #{inspect(id)} rows must be a positive integer"}

      true ->
        :ok
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

  defp valid_options?(options) when is_list(options) and options != [] do
    Enum.all?(options, fn
      {value, label} ->
        valid_scalar?(value) and is_binary(label)

      option when is_map(option) or is_list(option) ->
        option = normalize_map(option)
        valid_scalar?(Map.get(option, :value)) and is_binary(Map.get(option, :label))

      _other ->
        false
    end)
  end

  defp valid_options?(_options), do: false

  defp valid_form_fields?(fields) when is_list(fields) and fields != [] do
    Enum.all?(fields, fn
      field when is_map(field) or is_list(field) ->
        field = normalize_map(field)

        valid_scalar?(Map.get(field, :name)) and valid_scalar?(Map.get(field, :type)) and
          valid_field_attributes?(Map.get(field, :attributes))

      _other ->
        false
    end)
  end

  defp valid_form_fields?(_fields), do: false

  defp valid_field_attributes?(nil), do: true
  defp valid_field_attributes?(attributes) when is_map(attributes), do: true

  defp valid_field_attributes?(attributes) when is_list(attributes) do
    Keyword.keyword?(attributes)
  end

  defp valid_field_attributes?(_attributes), do: false

  defp valid_scalar?(nil), do: false
  defp valid_scalar?(value) when is_atom(value) or is_binary(value) or is_number(value), do: true
  defp valid_scalar?(_value), do: false

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
