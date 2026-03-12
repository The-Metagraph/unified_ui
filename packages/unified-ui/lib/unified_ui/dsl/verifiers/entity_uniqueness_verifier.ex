defmodule UnifiedUi.Dsl.Verifiers.EntityUniquenessVerifier do
  @moduledoc false

  use Spark.Dsl.Verifier

  alias Spark.Dsl.Verifier

  @impl true
  @spec verify(Spark.Dsl.t()) :: :ok | no_return()
  def verify(dsl_state) do
    module = Verifier.get_persisted(dsl_state, :module)

    extensions = Verifier.get_persisted(dsl_state, :extensions, [])

    Enum.each(extensions, fn extension ->
      Enum.each(extension.sections(), fn section ->
        verify_entity_uniqueness(module, section, dsl_state)
      end)
    end)

    :ok
  end

  defp verify_entity_uniqueness(module, section, dsl_state, path \\ []) do
    section_path = path ++ [section.name]
    entities_to_check = Verifier.get_entities(dsl_state, section_path)
    entities_by_struct = Enum.group_by(entities_to_check, & &1.__struct__)

    Enum.each(section.entities, fn entity ->
      entity
      |> Map.get(:target)
      |> then(&Map.get(entities_by_struct, &1, []))
      |> unique_entities_or_error(entity.identifier, module, section_path)

      verify_nested_entity_definitions(module, entity, section_path, entities_to_check)
    end)

    Enum.each(section.sections, fn nested_section ->
      verify_entity_uniqueness(module, nested_section, dsl_state, section_path)
    end)
  end

  defp verify_nested_entity_uniqueness(
         module,
         nested_entity,
         section_path,
         entities_to_check,
         nested_entity_path
       ) do
    unique_entities_or_error(
      entities_to_check,
      nested_entity.identifier,
      module,
      section_path ++ nested_entity_path
    )

    nested_children =
      nested_entity
      |> nested_entity_pairs()
      |> Enum.filter(fn {_key, nested_child} ->
        nested_child.identifier
      end)

    entities_to_check
    |> Enum.each(fn entity_to_check ->
      nested_children
      |> Enum.each(fn {key, nested_child} ->
        nested_entities_to_check =
          entity_to_check
          |> Map.get(key)
          |> List.wrap()

        verify_nested_entity_uniqueness(
          module,
          nested_child,
          section_path,
          nested_entities_to_check,
          nested_entity_path ++ [key]
        )
      end)
    end)
  end

  defp verify_nested_entity_definitions(module, entity, section_path, entities_to_check) do
    entity
    |> nested_entity_pairs()
    |> Enum.each(fn {key, nested_entity} ->
      verify_nested_entity_uniqueness(
        module,
        nested_entity,
        section_path,
        entities_to_check,
        [key]
      )
    end)
  end

  defp unique_entities_or_error(_entities_to_check, nil, _module, _path), do: :ok

  defp unique_entities_or_error(entities_to_check, identifier, module, path) do
    entities_to_check
    |> Enum.frequencies_by(&{get_identifier(&1, identifier), &1.__struct__})
    |> Enum.find_value(fn {key, value} ->
      if value > 1 do
        key
      end
    end)
    |> case do
      nil ->
        :ok

      {duplicate_identifier, target} ->
        raise Spark.Error.DslError,
          module: module,
          path: path ++ [duplicate_identifier],
          message: """
          Got duplicate #{inspect(target)}: #{duplicate_identifier}
          """
    end
  end

  defp get_identifier(record, {:auto, _}), do: record.__identifier__
  defp get_identifier(record, identifier), do: Map.get(record, identifier)

  defp nested_entity_pairs(entity) do
    case Map.get(entity, :entities) do
      entities when is_list(entities) ->
        Enum.flat_map(entities, fn
          {key, nested_entities} ->
            Enum.map(List.wrap(nested_entities), &{key, &1})

          _other ->
            []
        end)

      _ ->
        []
    end
  end
end
