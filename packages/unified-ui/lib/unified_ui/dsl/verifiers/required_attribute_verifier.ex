defmodule UnifiedUi.Dsl.Verifiers.RequiredAttributeVerifier do
  @moduledoc """
  Verifier that checks required attributes are present and type-compatible.

  Required attribute definitions are derived from DSL entity schemas declared
  in `UnifiedUi.Dsl.Extension`.
  """

  use Spark.Dsl.Verifier

  alias Spark.Dsl.Verifier
  alias UnifiedUi.Dsl.CompileIndex
  alias UnifiedUi.Dsl.Extension

  @impl true
  @spec verify(Spark.Dsl.t()) :: :ok | no_return()
  def verify(dsl_state) do
    module = Verifier.get_persisted(dsl_state, :module)
    required_specs = required_specs()

    dsl_state
    |> CompileIndex.get()
    |> Map.get(:flat, [])
    |> Enum.uniq()
    |> Enum.each(&verify_entity_required_attributes(module, &1, required_specs))

    :ok
  end

  defp verify_entity_required_attributes(_module, %{__struct__: struct}, required_specs)
       when not is_map_key(required_specs, struct),
       do: :ok

  defp verify_entity_required_attributes(module, %{__struct__: struct} = entity, required_specs) do
    required_specs
    |> Map.fetch!(struct)
    |> Enum.each(fn {key, type} ->
      verify_required_field(module, entity, key, type)
    end)
  end

  defp verify_entity_required_attributes(_module, _entity, _required_specs), do: :ok

  defp required_specs, do: build_required_specs()

  defp verify_required_field(module, entity, key, type) do
    value = Map.get(entity, key)
    entity_name = Keyword.get(Map.get(entity, :__meta__, []), :entity, inspect(entity.__struct__))

    if is_nil(value) do
      raise Spark.Error.DslError,
        module: module,
        path: [:ui],
        message: """
        Missing required attribute in #{entity_name}:

          #{inspect(key)} is required but was not provided.
        """
    end

    unless type_matches?(value, type) do
      raise Spark.Error.DslError,
        module: module,
        path: [:ui],
        message: """
        Invalid type for required attribute in #{entity_name}:

          #{inspect(key)}: #{inspect(value)}
          expected: #{inspect(type)}
        """
    end
  end

  defp build_required_specs do
    Extension.sections()
    |> Enum.flat_map(&collect_section_entities/1)
    |> Enum.flat_map(&collect_entity_specs/1)
    |> Enum.reduce(%{}, fn {target, required_fields}, acc ->
      Map.update(acc, target, required_fields, fn existing ->
        (existing ++ required_fields)
        |> Enum.uniq_by(fn {key, _type} -> key end)
      end)
    end)
  end

  defp collect_section_entities(section) do
    nested =
      section.sections
      |> List.wrap()
      |> Enum.flat_map(&collect_section_entities/1)

    List.wrap(section.entities) ++ nested
  end

  defp collect_entity_specs(entity) do
    required_fields =
      entity.schema
      |> List.wrap()
      |> Enum.flat_map(fn
        {key, opts} ->
          if Keyword.get(opts, :required, false) do
            [{key, Keyword.get(opts, :type, :any)}]
          else
            []
          end

        _other ->
          []
      end)

    current =
      if is_atom(entity.target) and required_fields != [] do
        [{entity.target, required_fields}]
      else
        []
      end

    nested =
      entity.entities
      |> nested_entity_defs()
      |> Enum.flat_map(&collect_entity_specs/1)

    current ++ nested
  end

  defp nested_entity_defs(entities) when is_list(entities) do
    Enum.flat_map(entities, fn
      {_key, nested_entities} when is_list(nested_entities) ->
        Enum.filter(nested_entities, &is_struct(&1, Spark.Dsl.Entity))

      {_key, %Spark.Dsl.Entity{} = entity} ->
        [entity]

      %Spark.Dsl.Entity{} = entity ->
        [entity]

      _other ->
        []
    end)
  end

  defp nested_entity_defs(_), do: []

  defp type_matches?(_value, :any), do: true
  defp type_matches?(value, :atom), do: is_atom(value)
  defp type_matches?(value, :string), do: is_binary(value)
  defp type_matches?(value, :boolean), do: is_boolean(value)
  defp type_matches?(value, :integer), do: is_integer(value)
  defp type_matches?(value, :non_neg_integer), do: is_integer(value) and value >= 0
  defp type_matches?(value, :pos_integer), do: is_integer(value) and value > 0
  defp type_matches?(value, :map), do: is_map(value)
  defp type_matches?(value, :keyword_list), do: is_list(value) and Keyword.keyword?(value)
  defp type_matches?(value, :list), do: is_list(value)

  defp type_matches?(value, {:list, subtype}) when is_list(value) do
    Enum.all?(value, &type_matches?(&1, subtype))
  end

  defp type_matches?(_value, {:list, _subtype}), do: false

  defp type_matches?(value, {:tuple, types})
       when is_tuple(value) and tuple_size(value) == length(types) do
    value
    |> Tuple.to_list()
    |> Enum.zip(types)
    |> Enum.all?(fn {tuple_value, tuple_type} -> type_matches?(tuple_value, tuple_type) end)
  end

  defp type_matches?(_value, {:tuple, _types}), do: false

  defp type_matches?(value, {:one_of, values}), do: value in values
  defp type_matches?(value, {:in, values}) when is_list(values), do: value in values
  defp type_matches?(value, {:in, %Range{} = range}), do: value in range
  defp type_matches?(value, {:literal, literal}), do: value == literal

  defp type_matches?(value, {:or, types}) when is_list(types) do
    Enum.any?(types, &type_matches?(value, &1))
  end

  # Ignore unsupported or Spark-specific type descriptors in this verifier.
  defp type_matches?(_value, _type), do: true
end
