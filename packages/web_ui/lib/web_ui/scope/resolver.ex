defmodule WebUi.Scope.Resolver do
  @moduledoc """
  Deterministic scope resolution helpers for runtime widget-event dispatch.
  """

  alias WebUi.TypedError

  @spec resolve_widget_scope(map(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def resolve_widget_scope(event_payload, runtime_context)
      when is_map(event_payload) and is_map(runtime_context) do
    correlation_id = fetch_string(runtime_context, :correlation_id) || "unknown"

    with {:ok, event_type} <- required_string(event_payload, :type, correlation_id),
         {:ok, data} <- required_map(event_payload, :data, correlation_id),
         {:ok, policy} <-
           normalize_scope_policy(fetch_any(runtime_context, :scope_policy), correlation_id),
         scope <- select_scope(data, runtime_context),
         :ok <- enforce_scope_policy(policy, scope, event_type, correlation_id) do
      {:ok, scope}
    end
  end

  def resolve_widget_scope(_event_payload, runtime_context) do
    {:error,
     TypedError.new(
       "scope.resolution.invalid_payload",
       "validation",
       false,
       %{reason: "event payload must be a map"},
       fetch_string(runtime_context, :correlation_id) || "unknown"
     )}
  end

  @spec attach_scope_metadata(map(), map()) :: map()
  def attach_scope_metadata(data, scope) when is_map(data) and is_map(scope) do
    data
    |> Map.put("scope_id", Map.fetch!(scope, :scope_id))
    |> Map.put("scope_type", Map.fetch!(scope, :scope_type))
    |> Map.put("scope_source", Map.fetch!(scope, :scope_source))
  end

  defp select_scope(data, runtime_context) when is_map(data) and is_map(runtime_context) do
    explicit_scope_id = fetch_string(data, :scope_id) || fetch_string(data, :scope)
    explicit_scope_type = fetch_string(data, :scope_type)
    context_scope_id = fetch_string(runtime_context, :scope_id)
    session_scope_id = fetch_string(runtime_context, :session_id)

    cond do
      is_binary(explicit_scope_id) ->
        %{
          scope_id: explicit_scope_id,
          scope_type: explicit_scope_type || "logical",
          scope_source: "event_data"
        }

      is_binary(context_scope_id) ->
        %{
          scope_id: context_scope_id,
          scope_type: fetch_string(runtime_context, :scope_type) || "logical",
          scope_source: "runtime_context"
        }

      is_binary(session_scope_id) ->
        %{
          scope_id: session_scope_id,
          scope_type: "session",
          scope_source: "session"
        }

      true ->
        %{
          scope_id: "global",
          scope_type: "global",
          scope_source: "default"
        }
    end
  end

  defp normalize_scope_policy(nil, _correlation_id) do
    {:ok,
     %{
       allow_scope_ids: MapSet.new(),
       deny_scope_ids: MapSet.new(),
       require_scope_for_event_types: MapSet.new()
     }}
  end

  defp normalize_scope_policy(policy, correlation_id) when is_map(policy) do
    with {:ok, allow_scope_ids} <- normalize_scope_list(policy, :allow_scope_ids, correlation_id),
         {:ok, deny_scope_ids} <- normalize_scope_list(policy, :deny_scope_ids, correlation_id),
         {:ok, require_scope_for_event_types} <-
           normalize_scope_list(policy, :require_scope_for_event_types, correlation_id) do
      {:ok,
       %{
         allow_scope_ids: MapSet.new(allow_scope_ids),
         deny_scope_ids: MapSet.new(deny_scope_ids),
         require_scope_for_event_types: MapSet.new(require_scope_for_event_types)
       }}
    end
  end

  defp normalize_scope_policy(_policy, correlation_id) do
    {:error,
     TypedError.new(
       "scope.resolution.invalid_scope_policy",
       "validation",
       false,
       %{reason: "scope_policy must be a map"},
       correlation_id
     )}
  end

  defp normalize_scope_list(policy, key, correlation_id) when is_map(policy) and is_atom(key) do
    value = fetch_any(policy, key, [])

    cond do
      is_nil(value) ->
        {:ok, []}

      is_list(value) ->
        {:ok, Enum.map(value, &normalize_string/1) |> Enum.reject(&is_nil/1) |> Enum.uniq()}

      true ->
        {:error,
         TypedError.new(
           "scope.resolution.invalid_scope_policy",
           "validation",
           false,
           %{reason: "#{key} must be a list"},
           correlation_id
         )}
    end
  end

  defp enforce_scope_policy(policy, scope, event_type, correlation_id)
       when is_map(policy) and is_map(scope) and is_binary(event_type) do
    scope_id = Map.fetch!(scope, :scope_id)
    scope_source = Map.fetch!(scope, :scope_source)

    cond do
      MapSet.member?(policy.deny_scope_ids, scope_id) ->
        {:error,
         TypedError.new(
           "scope.resolution.scope_denied",
           "authorization",
           false,
           %{scope_id: scope_id, policy_field: "deny_scope_ids"},
           correlation_id
         )}

      MapSet.size(policy.allow_scope_ids) > 0 and
          not MapSet.member?(policy.allow_scope_ids, scope_id) ->
        {:error,
         TypedError.new(
           "scope.resolution.scope_not_allowed",
           "authorization",
           false,
           %{scope_id: scope_id, policy_field: "allow_scope_ids"},
           correlation_id
         )}

      MapSet.member?(policy.require_scope_for_event_types, event_type) and
          scope_source == "default" ->
        {:error,
         TypedError.new(
           "scope.resolution.scope_required",
           "authorization",
           false,
           %{event_type: event_type, policy_field: "require_scope_for_event_types"},
           correlation_id
         )}

      true ->
        :ok
    end
  end

  defp required_string(map, key, correlation_id) when is_map(map) and is_atom(key) do
    case fetch_string(map, key) do
      nil ->
        {:error,
         TypedError.new(
           "scope.resolution.invalid_payload",
           "validation",
           false,
           %{reason: "missing or invalid #{key}"},
           correlation_id
         )}

      value ->
        {:ok, value}
    end
  end

  defp required_map(map, key, correlation_id) when is_map(map) and is_atom(key) do
    case fetch_any(map, key) do
      value when is_map(value) ->
        {:ok, value}

      _ ->
        {:error,
         TypedError.new(
           "scope.resolution.invalid_payload",
           "validation",
           false,
           %{reason: "missing or invalid #{key}"},
           correlation_id
         )}
    end
  end

  defp normalize_string(value) when is_binary(value) do
    value
    |> String.trim()
    |> case do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp normalize_string(value) when is_atom(value),
    do: value |> Atom.to_string() |> normalize_string()

  defp normalize_string(_value), do: nil

  defp fetch_any(map, key, default \\ nil) when is_map(map) and is_atom(key) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end

  defp fetch_string(map, key) when is_map(map) and is_atom(key) do
    case fetch_any(map, key) do
      value when is_binary(value) ->
        value
        |> String.trim()
        |> case do
          "" -> nil
          _ -> value
        end

      _ ->
        nil
    end
  end
end
