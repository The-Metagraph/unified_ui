defmodule WebUi.Policy.Authorizer do
  @moduledoc """
  Deterministic policy authorization checks for runtime widget events.
  """

  alias WebUi.TypedError

  @spec authorize_widget_event(map(), map()) :: :ok | {:error, TypedError.t()}
  def authorize_widget_event(event_payload, runtime_context)
      when is_map(event_payload) and is_map(runtime_context) do
    correlation_id = fetch_string(runtime_context, :correlation_id) || "unknown"
    policy = fetch_any(runtime_context, :policy)

    with {:ok, normalized_policy} <- normalize_policy(policy, correlation_id),
         {:ok, event_type} <- required_string(event_payload, :type, correlation_id),
         {:ok, widget_id} <- required_string(event_payload, :widget_id, correlation_id),
         :ok <- check_deny_event_types(normalized_policy, event_type, correlation_id),
         :ok <- check_deny_widget_ids(normalized_policy, widget_id, correlation_id),
         :ok <- check_allow_event_types(normalized_policy, event_type, correlation_id),
         :ok <-
           check_user_requirement(normalized_policy, event_type, runtime_context, correlation_id) do
      :ok
    end
  end

  def authorize_widget_event(_event_payload, runtime_context) do
    {:error,
     TypedError.new(
       "policy.authorization.invalid_payload",
       "validation",
       false,
       %{reason: "event payload must be a map"},
       fetch_string(runtime_context, :correlation_id) || "unknown"
     )}
  end

  defp normalize_policy(nil, _correlation_id) do
    {:ok,
     %{
       deny_event_types: MapSet.new(),
       deny_widget_ids: MapSet.new(),
       allow_event_types: MapSet.new(),
       require_user_for_event_types: MapSet.new()
     }}
  end

  defp normalize_policy(policy, correlation_id) when is_map(policy) do
    with {:ok, deny_event_types} <-
           normalize_policy_list(policy, :deny_event_types, correlation_id),
         {:ok, deny_widget_ids} <-
           normalize_policy_list(policy, :deny_widget_ids, correlation_id),
         {:ok, allow_event_types} <-
           normalize_policy_list(policy, :allow_event_types, correlation_id),
         {:ok, require_user_for_event_types} <-
           normalize_policy_list(policy, :require_user_for_event_types, correlation_id) do
      {:ok,
       %{
         deny_event_types: MapSet.new(deny_event_types),
         deny_widget_ids: MapSet.new(deny_widget_ids),
         allow_event_types: MapSet.new(allow_event_types),
         require_user_for_event_types: MapSet.new(require_user_for_event_types)
       }}
    end
  end

  defp normalize_policy(_policy, correlation_id) do
    {:error,
     TypedError.new(
       "policy.authorization.invalid_policy",
       "validation",
       false,
       %{reason: "policy must be a map"},
       correlation_id
     )}
  end

  defp normalize_policy_list(policy, key, correlation_id) when is_map(policy) and is_atom(key) do
    value = fetch_any(policy, key, [])

    cond do
      is_nil(value) ->
        {:ok, []}

      is_list(value) ->
        normalized =
          value
          |> Enum.map(&normalize_string/1)
          |> Enum.reject(&is_nil/1)
          |> Enum.uniq()

        {:ok, normalized}

      true ->
        {:error,
         TypedError.new(
           "policy.authorization.invalid_policy",
           "validation",
           false,
           %{reason: "#{key} must be a list"},
           correlation_id
         )}
    end
  end

  defp check_deny_event_types(policy, event_type, correlation_id)
       when is_map(policy) and is_binary(event_type) do
    if MapSet.member?(policy.deny_event_types, event_type) do
      {:error,
       TypedError.new(
         "policy.authorization.event_type_denied",
         "authorization",
         false,
         %{event_type: event_type, policy_field: "deny_event_types"},
         correlation_id
       )}
    else
      :ok
    end
  end

  defp check_deny_widget_ids(policy, widget_id, correlation_id)
       when is_map(policy) and is_binary(widget_id) do
    if MapSet.member?(policy.deny_widget_ids, widget_id) do
      {:error,
       TypedError.new(
         "policy.authorization.widget_id_denied",
         "authorization",
         false,
         %{widget_id: widget_id, policy_field: "deny_widget_ids"},
         correlation_id
       )}
    else
      :ok
    end
  end

  defp check_allow_event_types(policy, event_type, correlation_id)
       when is_map(policy) and is_binary(event_type) do
    allowlist = policy.allow_event_types

    if MapSet.size(allowlist) > 0 and not MapSet.member?(allowlist, event_type) do
      {:error,
       TypedError.new(
         "policy.authorization.event_type_not_allowed",
         "authorization",
         false,
         %{event_type: event_type, policy_field: "allow_event_types"},
         correlation_id
       )}
    else
      :ok
    end
  end

  defp check_user_requirement(policy, event_type, runtime_context, correlation_id)
       when is_map(policy) and is_binary(event_type) and is_map(runtime_context) do
    user_id = fetch_string(runtime_context, :user_id)

    if MapSet.member?(policy.require_user_for_event_types, event_type) and is_nil(user_id) do
      {:error,
       TypedError.new(
         "policy.authorization.user_required",
         "authorization",
         false,
         %{event_type: event_type, required_context_field: "user_id"},
         correlation_id
       )}
    else
      :ok
    end
  end

  defp required_string(map, key, correlation_id) when is_map(map) and is_atom(key) do
    case fetch_string(map, key) do
      nil ->
        {:error,
         TypedError.new(
           "policy.authorization.invalid_payload",
           "validation",
           false,
           %{reason: "missing or invalid #{key}"},
           correlation_id
         )}

      value ->
        {:ok, value}
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
