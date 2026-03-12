defmodule WebUi.FirstSlice.Workflow do
  @moduledoc """
  Canonical first implemented workflow: widget submit -> runtime save -> typed outcome.
  """

  alias WebUi.Agent
  alias WebUi.ServiceRequestEnvelope
  alias WebUi.TypedError

  @event_type "unified.form.submitted"
  @service "ui.preferences"
  @operation "save_preferences"

  @spec event_type() :: String.t()
  def event_type, do: @event_type

  @spec service() :: String.t()
  def service, do: @service

  @spec operation() :: String.t()
  def operation, do: @operation

  @spec agent(keyword()) :: {:ok, Agent.t()} | {:error, TypedError.t()}
  def agent(opts \\ []) when is_list(opts) do
    Agent.new(
      [
        %{
          event_type: @event_type,
          service: @service,
          operation: @operation,
          handler: &handle_request/1
        }
      ],
      opts
    )
  end

  @spec handle_request(ServiceRequestEnvelope.t()) :: {:ok, map()} | {:error, TypedError.t()}
  def handle_request(%ServiceRequestEnvelope{} = request) do
    data = request.payload.data

    with :ok <- validate_required_fields(data, request.context.correlation_id),
         :ok <- validate_action(data, request.context.correlation_id) do
      preference_key = fetch_any(data, :preference_key)
      value = fetch_any(data, :value)

      {:ok,
       %{
         status: "saved",
         preference: %{key: preference_key, value: value},
         ui_patch: %{notice: "Preference saved", state: "saved", field: preference_key},
         ui_hints: %{
           primary_notice: "Saved preference for " <> preference_key,
           severity: "info",
           next_actions: ["continue_editing", "submit_another_change"],
           focus_field: preference_key
         },
         events: [
           %{
             event_name: "runtime.first_slice.preference_saved.v1",
             event_version: "v1",
             timestamp: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
             service: @service,
             source: "WebUi.FirstSlice.Workflow",
             correlation_id: request.context.correlation_id,
             request_id: request.context.request_id,
             outcome: "ok",
             payload: %{preference_key: preference_key, value: value}
           }
         ]
       }}
    end
  end

  def handle_request(_request) do
    {:error,
     TypedError.new(
       "first_slice.invalid_request",
       "validation",
       false,
       %{reason: "request must be ServiceRequestEnvelope"}
     )}
  end

  defp validate_required_fields(data, correlation_id) when is_map(data) do
    missing =
      [:preference_key, :value]
      |> Enum.filter(fn key ->
        case fetch_any(data, key) do
          value when is_binary(value) and value != "" -> false
          _ -> true
        end
      end)

    case missing do
      [] ->
        :ok

      _ ->
        {:error,
         TypedError.new(
           "first_slice.missing_required_fields",
           "validation",
           false,
           %{missing_fields: missing},
           correlation_id
         )}
    end
  end

  defp validate_required_fields(_data, correlation_id) do
    {:error,
     TypedError.new(
       "first_slice.invalid_payload",
       "validation",
       false,
       %{reason: "request payload data must be a map"},
       correlation_id
     )}
  end

  defp validate_action(data, correlation_id) do
    action = fetch_any(data, :action)

    case action do
      value when value in [nil, "submit", "save_preferences"] ->
        :ok

      "cancel" ->
        {:error,
         TypedError.new(
           "first_slice.cancelled",
           "validation",
           false,
           %{action: action},
           correlation_id
         )}

      "retryable_failure" ->
        {:error,
         TypedError.new(
           "first_slice.retryable_dependency_error",
           "dependency",
           true,
           %{action: action},
           correlation_id
         )}

      _ ->
        {:error,
         TypedError.new(
           "first_slice.unsupported_action",
           "validation",
           false,
           %{action: action},
           correlation_id
         )}
    end
  end

  defp fetch_any(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end
end
