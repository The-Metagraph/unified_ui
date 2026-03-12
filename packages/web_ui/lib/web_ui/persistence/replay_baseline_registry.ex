defmodule WebUi.Persistence.ReplayBaselineRegistry do
  @moduledoc """
  Deterministic in-memory replay baseline registry helpers.
  """

  alias WebUi.TypedError

  @type baseline_id :: String.t()

  @type t :: %{
          baselines: %{optional(baseline_id()) => map()},
          order: [baseline_id()],
          active_baseline_id: baseline_id() | nil,
          retention_limit: pos_integer() | nil
        }

  @spec new(map()) :: t()
  def new(opts \\ %{}) when is_map(opts) do
    retention_limit =
      case fetch_any(opts, :retention_limit) do
        limit when is_integer(limit) and limit > 0 -> limit
        _ -> nil
      end

    %{
      baselines: %{},
      order: [],
      active_baseline_id: nil,
      retention_limit: retention_limit
    }
  end

  @spec upsert(t(), map(), map()) :: {:ok, t()} | {:error, TypedError.t()}
  def upsert(registry, baseline, opts \\ %{})

  def upsert(registry, baseline, opts)
      when is_map(registry) and is_map(baseline) and is_map(opts) do
    with {:ok, registry} <- normalize_registry(registry),
         {:ok, baseline_id} <- baseline_id_from_baseline(baseline),
         {:ok, retention_limit} <-
           normalize_retention_limit(
             fetch_any(opts, :retention_limit),
             fetch_any(registry, :retention_limit)
           ),
         {:ok, activate?} <- normalize_activate(fetch_any(opts, :activate), true) do
      baselines =
        registry
        |> fetch_any(:baselines)
        |> Map.put(baseline_id, baseline)

      order =
        baselines
        |> Map.values()
        |> Enum.sort_by(&baseline_sort_key/1, :desc)
        |> Enum.map(fn baseline_entry -> fetch_any(baseline_entry, :baseline_id) end)

      retained_order =
        if is_integer(retention_limit) do
          Enum.take(order, retention_limit)
        else
          order
        end

      retained_baselines = Map.take(baselines, retained_order)

      active_baseline_id =
        resolve_active_baseline_id(
          retained_order,
          fetch_any(registry, :active_baseline_id),
          baseline_id,
          activate?
        )

      {:ok,
       %{
         baselines: retained_baselines,
         order: retained_order,
         active_baseline_id: active_baseline_id,
         retention_limit: retention_limit
       }}
    end
  end

  def upsert(registry, baseline, opts) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_registry",
       "validation",
       false,
       %{
         reason: "registry, baseline, and options must be maps",
         registry: registry,
         baseline: baseline,
         opts: opts
       }
     )}
  end

  @spec fetch(t(), baseline_id()) :: {:ok, map()} | {:error, TypedError.t()}
  def fetch(registry, baseline_id) when is_map(registry) and is_binary(baseline_id) do
    with {:ok, normalized_registry} <- normalize_registry(registry) do
      case fetch_any(normalized_registry.baselines, baseline_id) do
        baseline when is_map(baseline) ->
          {:ok, baseline}

        _ ->
          {:error,
           TypedError.new(
             "replay_baseline_registry.baseline_not_found",
             "validation",
             false,
             %{reason: "baseline_id is not present in registry", baseline_id: baseline_id}
           )}
      end
    end
  end

  def fetch(registry, baseline_id) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_registry",
       "validation",
       false,
       %{
         reason: "registry must be map and baseline_id must be string",
         registry: registry,
         baseline_id: baseline_id
       }
     )}
  end

  @spec activate(t(), baseline_id()) :: {:ok, t()} | {:error, TypedError.t()}
  def activate(registry, baseline_id) when is_map(registry) and is_binary(baseline_id) do
    with {:ok, normalized_registry} <- normalize_registry(registry),
         {:ok, _baseline} <- fetch(normalized_registry, baseline_id) do
      {:ok, Map.put(normalized_registry, :active_baseline_id, baseline_id)}
    end
  end

  def activate(registry, baseline_id) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_registry",
       "validation",
       false,
       %{
         reason: "registry must be map and baseline_id must be string",
         registry: registry,
         baseline_id: baseline_id
       }
     )}
  end

  @spec active(t()) :: {:ok, map()} | {:error, TypedError.t()}
  def active(registry) when is_map(registry) do
    with {:ok, normalized_registry} <- normalize_registry(registry) do
      case fetch_any(normalized_registry, :active_baseline_id) do
        baseline_id when is_binary(baseline_id) and baseline_id != "" ->
          fetch(normalized_registry, baseline_id)

        _ ->
          {:error,
           TypedError.new(
             "replay_baseline_registry.active_baseline_missing",
             "validation",
             false,
             %{reason: "active baseline is not set"}
           )}
      end
    end
  end

  def active(registry) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_registry",
       "validation",
       false,
       %{reason: "registry must be a map", registry: registry}
     )}
  end

  @spec list(t()) :: {:ok, [map()]} | {:error, TypedError.t()}
  def list(registry) when is_map(registry) do
    with {:ok, normalized_registry} <- normalize_registry(registry) do
      baselines = fetch_any(normalized_registry, :baselines)
      order = fetch_any(normalized_registry, :order)

      ordered_baselines =
        order
        |> Enum.map(fn baseline_id -> fetch_any(baselines, baseline_id) end)
        |> Enum.filter(&is_map/1)

      {:ok, ordered_baselines}
    end
  end

  def list(registry) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_registry",
       "validation",
       false,
       %{reason: "registry must be a map", registry: registry}
     )}
  end

  defp normalize_registry(registry) when is_map(registry) do
    baselines = fetch_any(registry, :baselines)
    order = fetch_any(registry, :order)
    active_baseline_id = fetch_any(registry, :active_baseline_id)

    with {:ok, normalized_baselines} <- normalize_baselines(baselines, registry),
         {:ok, normalized_order} <- normalize_order(order, normalized_baselines, registry),
         {:ok, normalized_active_id} <-
           normalize_active_baseline_id(active_baseline_id, normalized_order, registry),
         {:ok, retention_limit} <-
           normalize_retention_limit(fetch_any(registry, :retention_limit), nil) do
      {:ok,
       %{
         baselines: normalized_baselines,
         order: normalized_order,
         active_baseline_id: normalized_active_id,
         retention_limit: retention_limit
       }}
    end
  end

  defp normalize_baselines(baselines, _registry) when is_map(baselines) do
    baselines
    |> Enum.reduce_while({:ok, %{}}, fn {baseline_id, baseline}, {:ok, acc} ->
      case normalize_baseline_entry(baseline_id, baseline) do
        {:ok, normalized_id, normalized_baseline} ->
          {:cont, {:ok, Map.put(acc, normalized_id, normalized_baseline)}}

        {:error, _error} = error ->
          {:halt, error}
      end
    end)
  end

  defp normalize_baselines(_baselines, registry) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_registry",
       "validation",
       false,
       %{reason: "registry baselines must be a map", registry: registry}
     )}
  end

  defp normalize_baseline_entry(baseline_id, baseline)
       when is_binary(baseline_id) and is_map(baseline) do
    with {:ok, parsed_id} <- baseline_id_from_baseline(baseline) do
      if parsed_id == baseline_id do
        {:ok, baseline_id, baseline}
      else
        {:error,
         TypedError.new(
           "replay_baseline_registry.invalid_registry",
           "validation",
           false,
           %{
             reason: "registry baseline key must match baseline payload baseline_id",
             baseline_id: baseline_id,
             parsed_id: parsed_id
           }
         )}
      end
    end
  end

  defp normalize_baseline_entry(baseline_id, baseline) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_registry",
       "validation",
       false,
       %{
         reason: "registry baselines must map string baseline_id keys to maps",
         baseline_id: baseline_id,
         baseline: baseline
       }
     )}
  end

  defp normalize_order(order, baselines, _registry) when is_list(order) and is_map(baselines) do
    cond do
      Enum.any?(order, &(not is_binary(&1) or &1 == "")) ->
        {:error,
         TypedError.new(
           "replay_baseline_registry.invalid_registry",
           "validation",
           false,
           %{reason: "registry order must contain non-empty baseline_id strings"}
         )}

      Enum.uniq(order) != order ->
        {:error,
         TypedError.new(
           "replay_baseline_registry.invalid_registry",
           "validation",
           false,
           %{reason: "registry order baseline_id values must be unique"}
         )}

      Enum.any?(Map.keys(baselines), fn baseline_id -> baseline_id not in order end) ->
        {:error,
         TypedError.new(
           "replay_baseline_registry.invalid_registry",
           "validation",
           false,
           %{reason: "registry order must include every stored baseline_id"}
         )}

      true ->
        {:ok, order}
    end
  end

  defp normalize_order(_order, _baselines, registry) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_registry",
       "validation",
       false,
       %{reason: "registry order must be a list", registry: registry}
     )}
  end

  defp normalize_active_baseline_id(nil, _order, _registry), do: {:ok, nil}

  defp normalize_active_baseline_id(active_baseline_id, order, _registry)
       when is_binary(active_baseline_id) do
    if active_baseline_id in order do
      {:ok, active_baseline_id}
    else
      {:error,
       TypedError.new(
         "replay_baseline_registry.invalid_registry",
         "validation",
         false,
         %{
           reason: "registry active_baseline_id must reference an ID present in order",
           active_baseline_id: active_baseline_id
         }
       )}
    end
  end

  defp normalize_active_baseline_id(active_baseline_id, _order, registry) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_registry",
       "validation",
       false,
       %{
         reason: "registry active_baseline_id must be a string or nil",
         active_baseline_id: active_baseline_id,
         registry: registry
       }
     )}
  end

  defp normalize_retention_limit(nil, default), do: {:ok, default}

  defp normalize_retention_limit(limit, _default) when is_integer(limit) and limit > 0,
    do: {:ok, limit}

  defp normalize_retention_limit(limit, _default) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_options",
       "validation",
       false,
       %{
         reason: "retention_limit must be a positive integer when provided",
         retention_limit: limit
       }
     )}
  end

  defp normalize_activate(nil, default), do: {:ok, default}
  defp normalize_activate(value, _default) when is_boolean(value), do: {:ok, value}

  defp normalize_activate(value, _default) do
    {:error,
     TypedError.new(
       "replay_baseline_registry.invalid_options",
       "validation",
       false,
       %{reason: "activate must be a boolean when provided", activate: value}
     )}
  end

  defp baseline_id_from_baseline(baseline) when is_map(baseline) do
    case fetch_any(baseline, :baseline_id) do
      baseline_id when is_binary(baseline_id) and baseline_id != "" ->
        {:ok, baseline_id}

      baseline_id ->
        {:error,
         TypedError.new(
           "replay_baseline_registry.invalid_baseline",
           "validation",
           false,
           %{
             reason: "baseline must include non-empty baseline_id",
             baseline_id: baseline_id,
             baseline: baseline
           }
         )}
    end
  end

  defp baseline_sort_key(baseline) when is_map(baseline) do
    {
      baseline_cursor(baseline),
      fetch_any(baseline, :checkpoint_id) || "",
      fetch_any(baseline, :baseline_id) || ""
    }
  end

  defp baseline_cursor(baseline) when is_map(baseline) do
    case fetch_any(baseline, :cursor) do
      value when is_integer(value) and value >= 0 -> value
      _ -> -1
    end
  end

  defp resolve_active_baseline_id(order, previous_active_baseline_id, inserted_baseline_id, true)
       when is_list(order) and is_binary(inserted_baseline_id) do
    if inserted_baseline_id in order do
      inserted_baseline_id
    else
      resolve_active_baseline_id(order, previous_active_baseline_id, inserted_baseline_id, false)
    end
  end

  defp resolve_active_baseline_id(
         order,
         previous_active_baseline_id,
         _inserted_baseline_id,
         false
       )
       when is_list(order) do
    cond do
      is_binary(previous_active_baseline_id) and previous_active_baseline_id in order ->
        previous_active_baseline_id

      true ->
        List.first(order)
    end
  end

  defp fetch_any(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp fetch_any(map, key) when is_map(map) and is_binary(key) do
    Map.get(map, key)
  end
end
