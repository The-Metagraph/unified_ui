defmodule WebUi.Observability.Metrics do
  @moduledoc """
  Metric family registry and bounded-label instrumentation helpers.
  """

  alias WebUi.TypedError

  @metric_specs %{
    "webui_ws_connection_total" => %{type: :counter, required_labels: ["endpoint", "outcome"]},
    "webui_ws_disconnect_total" => %{type: :counter, required_labels: ["endpoint", "reason"]},
    "webui_event_ingress_total" => %{type: :counter, required_labels: ["service", "event_type", "outcome"]},
    "webui_event_egress_total" => %{type: :counter, required_labels: ["service", "event_type", "outcome"]},
    "webui_event_decode_error_total" => %{type: :counter, required_labels: ["service", "error_code"]},
    "webui_event_encode_error_total" => %{type: :counter, required_labels: ["service", "error_code"]},
    "webui_service_operation_latency" => %{type: :histogram, required_labels: ["service", "operation", "outcome"]},
    "webui_js_interop_error_total" => %{type: :counter, required_labels: ["bridge", "error_code"]}
  }

  @disallowed_label_keys MapSet.new(["payload", "prompt", "correlation_id", "request_id", "session_id", "trace_id", "user_id"])
  @label_value_regex ~r/^[A-Za-z0-9_.:-]{1,64}$/

  @type t :: %{
          counters: %{String.t() => non_neg_integer()},
          histograms: %{String.t() => [number()]},
          records: [map()]
        }

  @spec new() :: t()
  def new, do: %{counters: %{}, histograms: %{}, records: []}

  @spec metric_specs() :: map()
  def metric_specs, do: @metric_specs

  @spec required_metric_names() :: [String.t()]
  def required_metric_names do
    @metric_specs
    |> Map.keys()
    |> Enum.sort()
  end

  @spec metric_record(String.t(), map(), number(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def metric_record(metric_name, labels, value, context \\ %{})

  def metric_record(metric_name, labels, value, context)
      when is_binary(metric_name) and is_map(labels) and is_map(context) do
    with {:ok, spec} <- metric_spec(metric_name),
         :ok <- validate_labels(metric_name, labels, spec.required_labels),
         :ok <- validate_metric_value(spec.type, value) do
      {:ok,
       %{
         metric_name: metric_name,
         metric_type: spec.type,
         value: value,
         labels: normalize_labels(labels),
         correlation_id: fetch_any(context, :correlation_id),
         request_id: fetch_any(context, :request_id),
         timestamp: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601()
       }}
    end
  end

  def metric_record(_metric_name, _labels, _value, _context) do
    {:error,
     TypedError.new(
       "observability.metric_invalid_shape",
       "validation",
       false,
       %{reason: "metric_name must be a string and labels/context must be maps"}
     )}
  end

  @spec record(t(), String.t(), map(), number(), map()) :: {:ok, t(), map()} | {:error, TypedError.t()}
  def record(%{counters: _counters, histograms: _histograms, records: _records} = state, metric_name, labels, value, context \\ %{}) do
    with {:ok, record} <- metric_record(metric_name, labels, value, context) do
      updated_state =
        case record.metric_type do
          :counter ->
            key = metric_key(record.metric_name, record.labels)
            counters = Map.update(state.counters, key, trunc(value), &(&1 + trunc(value)))
            %{state | counters: counters, records: [record | state.records]}

          :histogram ->
            key = metric_key(record.metric_name, record.labels)
            histograms = Map.update(state.histograms, key, [value], &[value | &1])
            %{state | histograms: histograms, records: [record | state.records]}
        end

      {:ok, updated_state, record}
    end
  end

  @spec counter_value(t(), String.t(), map()) :: non_neg_integer()
  def counter_value(state, metric_name, labels) when is_map(state) and is_binary(metric_name) and is_map(labels) do
    Map.get(state.counters, metric_key(metric_name, normalize_labels(labels)), 0)
  end

  @spec histogram_samples(t(), String.t(), map()) :: [number()]
  def histogram_samples(state, metric_name, labels) when is_map(state) and is_binary(metric_name) and is_map(labels) do
    state
    |> Map.get(:histograms, %{})
    |> Map.get(metric_key(metric_name, normalize_labels(labels)), [])
    |> Enum.reverse()
  end

  @spec records(t()) :: [map()]
  def records(state) when is_map(state) do
    state
    |> Map.get(:records, [])
    |> Enum.reverse()
  end

  @spec metric_spec(String.t()) :: {:ok, map()} | {:error, TypedError.t()}
  def metric_spec(metric_name) when is_binary(metric_name) do
    case Map.get(@metric_specs, metric_name) do
      nil ->
        {:error,
         TypedError.new(
           "observability.metric_unknown",
           "validation",
           false,
           %{metric_name: metric_name}
         )}

      spec ->
        {:ok, spec}
    end
  end

  @spec validate_labels(String.t(), map(), [String.t()]) :: :ok | {:error, TypedError.t()}
  def validate_labels(metric_name, labels, required_labels)
      when is_binary(metric_name) and is_map(labels) and is_list(required_labels) do
    normalized = normalize_labels(labels)
    keys = normalized |> Map.keys() |> Enum.sort()
    expected = Enum.sort(required_labels)
    invalid_values = invalid_label_values(normalized)

    cond do
      keys != expected ->
        {:error,
         TypedError.new(
           "observability.metric_invalid_labels",
           "validation",
           false,
           %{metric_name: metric_name, required_labels: expected, actual_labels: keys}
         )}

      Enum.any?(keys, &MapSet.member?(@disallowed_label_keys, &1)) ->
        {:error,
         TypedError.new(
           "observability.metric_high_cardinality_label",
           "validation",
           false,
           %{metric_name: metric_name, labels: keys}
         )}

      invalid_values != [] ->
        {:error,
         TypedError.new(
           "observability.metric_invalid_label_value",
           "validation",
           false,
           %{metric_name: metric_name, invalid_values: invalid_values}
         )}

      true ->
        :ok
    end
  end

  def validate_labels(_metric_name, _labels, _required_labels) do
    {:error,
     TypedError.new(
       "observability.metric_invalid_labels",
       "validation",
       false,
       %{reason: "labels must be a map and required_labels must be a list"}
     )}
  end

  defp validate_metric_value(:counter, value) when is_integer(value) and value >= 0, do: :ok
  defp validate_metric_value(:counter, value) when is_float(value) and value >= 0, do: :ok
  defp validate_metric_value(:histogram, value) when is_integer(value) or is_float(value), do: :ok

  defp validate_metric_value(_type, value) do
    {:error,
     TypedError.new(
       "observability.metric_invalid_value",
       "validation",
       false,
       %{value: inspect(value)}
     )}
  end

  defp normalize_labels(labels) do
    labels
    |> Enum.map(fn {key, value} -> {to_string(key), to_string(value)} end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.into(%{})
  end

  defp invalid_label_values(labels) do
    labels
    |> Enum.reduce([], fn {key, value}, acc ->
      if Regex.match?(@label_value_regex, value) do
        acc
      else
        [%{label: key, value: value} | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp metric_key(metric_name, labels) do
    [metric_name | Enum.map(labels, fn {k, v} -> "#{k}=#{v}" end)]
    |> Enum.join("|")
  end

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
