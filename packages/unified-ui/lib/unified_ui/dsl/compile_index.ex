defmodule UnifiedUi.Dsl.CompileIndex do
  @moduledoc false

  alias Spark.Dsl.Transformer

  @persist_key :unified_ui_compile_index
  @runtime_view_state_cache_key :unified_ui_runtime_view_state
  @nested_entity_keys [:entities, :children, :items, :tabs, :nodes, :columns]

  @type t :: %{
          widgets: list(),
          layouts: list(),
          ui: list(),
          styles: list(),
          state: list(),
          flat: list()
        }

  @spec get(Spark.Dsl.t()) :: t()
  def get(dsl_state) do
    Transformer.get_persisted(dsl_state, @persist_key) || build(dsl_state)
  end

  @spec persist(Spark.Dsl.t()) :: Spark.Dsl.t()
  def persist(dsl_state) do
    Transformer.persist(dsl_state, @persist_key, build(dsl_state))
  end

  @spec view_state(Spark.Dsl.t()) :: map()
  def view_state(dsl_state) do
    index = get(dsl_state)

    base_state = %{
      :ui => %{entities: index.ui},
      [:ui] => %{entities: index.ui},
      :styles => %{entities: index.styles}
    }

    case Transformer.get_persisted(dsl_state, :module) do
      nil -> base_state
      module -> Map.put(base_state, :persist, %{module: module})
    end
  end

  @spec runtime_view_state(module()) :: map()
  def runtime_view_state(module) when is_atom(module) do
    cache_key = {@runtime_view_state_cache_key, module}

    case :persistent_term.get(cache_key, :missing) do
      :missing ->
        view_state = build_runtime_view_state(module)
        :persistent_term.put(cache_key, view_state)
        view_state

      view_state ->
        view_state
    end
  end

  @spec invalidate_runtime_view_state(module() | nil) :: :ok
  def invalidate_runtime_view_state(module) when is_atom(module) do
    cache_key = {@runtime_view_state_cache_key, module}
    _ = :persistent_term.erase(cache_key)
    :ok
  end

  def invalidate_runtime_view_state(_), do: :ok

  @spec build(Spark.Dsl.t()) :: t()
  def build(dsl_state) do
    widgets = safe_get_entities(dsl_state, :widgets)
    layouts = safe_get_entities(dsl_state, :layouts)
    ui_entities = collect_ui_entities(dsl_state)
    styles_entities = collect_styles_entities(dsl_state)
    state_entities = collect_state_entities(dsl_state, ui_entities)

    roots =
      [widgets, layouts, ui_entities]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)

    %{
      widgets: widgets,
      layouts: layouts,
      ui: ui_entities,
      styles: styles_entities,
      state: state_entities,
      flat: flatten_entities(roots)
    }
  end

  defp collect_ui_entities(dsl_state) do
    entities =
      [
        safe_get_entities(dsl_state, [:ui]),
        safe_get_entities(dsl_state, :ui)
      ]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)

    if entities == [] do
      dsl_state
      |> Map.get(:ui, %{})
      |> Map.get(:entities, [])
      |> List.wrap()
      |> Enum.reject(&is_nil/1)
    else
      entities
    end
  end

  defp collect_state_entities(dsl_state, ui_entities) do
    entities = safe_get_entities(dsl_state, [:ui, :state])

    if entities == [] do
      nested_state_entities =
        dsl_state
        |> Map.get(:ui, %{})
        |> Map.get(:state, %{})
        |> Map.get(:entities, [])
        |> List.wrap()
        |> Enum.reject(&is_nil/1)

      if nested_state_entities == [] do
        Enum.filter(ui_entities, &state_entity?/1)
      else
        nested_state_entities
      end
    else
      entities
    end
  end

  defp state_entity?(%UnifiedUi.Dsl.State{}), do: true
  defp state_entity?(%{name: :state}), do: true
  defp state_entity?(_), do: false

  defp build_runtime_view_state(module) do
    ui_entities =
      runtime_entities(module, [:ui])
      |> fallback_runtime_entities(module, :ui)

    styles_entities =
      runtime_entities(module, [:styles])
      |> fallback_runtime_entities(module, :styles)

    %{
      :ui => %{entities: ui_entities},
      [:ui] => %{entities: ui_entities},
      :styles => %{entities: styles_entities},
      :persist => %{module: module}
    }
  end

  defp runtime_entities(module, path) do
    module
    |> Spark.Dsl.Extension.get_entities(path)
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
  rescue
    _ -> []
  catch
    _, _ -> []
  end

  defp fallback_runtime_entities([], module, fallback_path),
    do: runtime_entities(module, fallback_path)

  defp fallback_runtime_entities(entities, _module, _fallback_path), do: entities

  defp collect_styles_entities(dsl_state) do
    entities = safe_get_entities(dsl_state, :styles)

    if entities == [] do
      dsl_state
      |> Map.get(:styles, %{})
      |> Map.get(:entities, [])
      |> List.wrap()
      |> Enum.reject(&is_nil/1)
    else
      entities
    end
  end

  defp safe_get_entities(dsl_state, path) do
    dsl_state
    |> Transformer.get_entities(path)
    |> List.wrap()
    |> Enum.reject(&is_nil/1)
  rescue
    _ -> []
  catch
    _, _ -> []
  end

  defp flatten_entities(entities) when is_list(entities) do
    Enum.flat_map(entities, &flatten_entity/1)
  end

  defp flatten_entity(entity) when is_map(entity) do
    nested =
      @nested_entity_keys
      |> Enum.flat_map(fn key ->
        case Map.get(entity, key) do
          values when is_list(values) -> values
          _ -> []
        end
      end)

    [entity | flatten_entities(nested)]
  end

  defp flatten_entity(entity), do: [entity]
end
