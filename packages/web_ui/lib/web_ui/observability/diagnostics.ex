defmodule WebUi.Observability.Diagnostics do
  @moduledoc """
  Correlation joinability and denied-path diagnostic helpers.
  """

  alias WebUi.Observability.RuntimeEvent
  alias WebUi.TypedError

  @sensitive_keys ~w(password token secret prompt payload raw_payload input_data user_text authorization cookie set_cookie)
  @guidance_map %{
    "widget.extension_action_denied" => "Denied extension actions usually indicate policy enforcement for runtime authority boundaries.",
    "agent.context_integrity_mismatch" => "Context mismatch indicates correlation/request drift between ingress envelope and dispatch context.",
    "runtime_context.missing_required_fields" => "Missing correlation/request identifiers prevent cross-stream diagnostics and must be fixed at ingress."
  }

  @spec joinable?(map(), map()) :: boolean()
  def joinable?(event, metric_record) when is_map(event) and is_map(metric_record) do
    event_corr = fetch_any(event, :correlation_id)
    event_req = fetch_any(event, :request_id)

    metric_corr = fetch_any(metric_record, :correlation_id)
    metric_req = fetch_any(metric_record, :request_id)

    is_binary(event_corr) and event_corr != "" and
      is_binary(event_req) and event_req != "" and
      event_corr == metric_corr and event_req == metric_req
  end

  def joinable?(_event, _metric_record), do: false

  @spec joinability_report([map()], [map()]) :: {:ok, map()} | {:error, TypedError.t()}
  def joinability_report(events, metric_records) when is_list(events) and is_list(metric_records) do
    missing_event_context =
      events
      |> Enum.filter(&is_map/1)
      |> Enum.filter(fn event -> not valid_context?(event) end)

    missing_metric_context =
      metric_records
      |> Enum.filter(&is_map/1)
      |> Enum.filter(fn record -> not valid_context?(record) end)

    joined_pairs =
      for event <- events,
          metric <- metric_records,
          is_map(event),
          is_map(metric),
          joinable?(event, metric),
          do: %{event_name: fetch_any(event, :event_name), metric_name: fetch_any(metric, :metric_name)}

    report = %{
      event_count: length(Enum.filter(events, &is_map/1)),
      metric_record_count: length(Enum.filter(metric_records, &is_map/1)),
      joinable_pairs: joined_pairs,
      missing_event_context_count: length(missing_event_context),
      missing_metric_context_count: length(missing_metric_context)
    }

    if report.missing_event_context_count == 0 and report.missing_metric_context_count == 0 do
      {:ok, report}
    else
      {:error,
       TypedError.new(
         "observability.joinability_context_missing",
         "validation",
         false,
         report
       )}
    end
  end

  def joinability_report(_events, _metric_records) do
    {:error,
     TypedError.new(
       "observability.joinability_invalid_shape",
       "validation",
       false,
       %{reason: "events and metric_records must be lists"}
     )}
  end

  @spec redact_payload(map()) :: map()
  def redact_payload(payload) when is_map(payload) do
    payload
    |> Enum.map(fn {key, value} ->
      normalized_key = to_string(key)

      if normalized_key in @sensitive_keys do
        {normalized_key, "[REDACTED]"}
      else
        {normalized_key, redact_value(value)}
      end
    end)
    |> Enum.into(%{})
  end

  def redact_payload(_payload), do: %{}

  @spec denied_path_event(String.t(), String.t(), String.t(), map(), TypedError.t(), map()) :: map()
  def denied_path_event(event_name, source, service, context, %TypedError{} = error, payload \\ %{})
      when is_binary(event_name) and is_binary(source) and is_binary(service) and is_map(context) and is_map(payload) do
    {:ok, event} =
      RuntimeEvent.build(
        %{
          event_name: event_name,
          event_version: "v1",
          source: source,
          service: service,
          outcome: "error",
          payload: %{
            error_code: error.error_code,
            category: error.category,
            guidance: guidance_for(error.error_code),
            details: redact_payload(error.details || %{}),
            denied_payload: redact_payload(payload)
          }
        },
        %{
          correlation_id: fetch_any(context, :correlation_id) || error.correlation_id,
          request_id: fetch_any(context, :request_id) || "unknown",
          session_id: fetch_any(context, :session_id),
          client_id: fetch_any(context, :client_id)
        }
      )

    event
  end

  @spec guidance_for(String.t()) :: String.t()
  def guidance_for(error_code) when is_binary(error_code) do
    Map.get(@guidance_map, error_code, "Inspect typed error category/details and correlate with runtime transport and service events.")
  end

  def guidance_for(_error_code), do: "Inspect typed error category/details and correlate with runtime transport and service events."

  defp valid_context?(map) when is_map(map) do
    valid_id?(fetch_any(map, :correlation_id)) and valid_id?(fetch_any(map, :request_id))
  end

  defp valid_context?(_map), do: false

  defp valid_id?(value), do: is_binary(value) and value != ""

  defp redact_value(value) when is_map(value), do: redact_payload(value)
  defp redact_value(value) when is_list(value), do: Enum.map(value, &redact_value/1)
  defp redact_value(value), do: value

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
