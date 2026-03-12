defmodule WebUi.Release.Readiness do
  @moduledoc """
  Rollback decision helper for release-governance observable signal thresholds.
  """

  @default_thresholds %{
    decode_error_ratio: 2.0,
    encode_error_ratio: 2.0,
    service_latency_p95_ratio: 2.0,
    retryable_error_budget_ratio: 1.0,
    joinability_failures: 0
  }

  @type snapshot :: %{
          optional(:decode_error_ratio) => number(),
          optional(:encode_error_ratio) => number(),
          optional(:service_latency_p95_ratio) => number(),
          optional(:retryable_error_budget_ratio) => number(),
          optional(:joinability_failures) => non_neg_integer()
        }

  @spec thresholds() :: map()
  def thresholds, do: @default_thresholds

  @spec rollback_decision(snapshot(), map()) ::
          {:go, %{reasons: [String.t()]}} | {:rollback, %{reasons: [String.t()]}}
  def rollback_decision(snapshot, threshold_overrides \\ %{})
      when is_map(snapshot) and is_map(threshold_overrides) do
    thresholds = Map.merge(@default_thresholds, threshold_overrides)

    reasons =
      []
      |> maybe_append_ratio_reason(
        "decode_error_ratio",
        Map.get(snapshot, :decode_error_ratio, 0.0),
        thresholds.decode_error_ratio
      )
      |> maybe_append_ratio_reason(
        "encode_error_ratio",
        Map.get(snapshot, :encode_error_ratio, 0.0),
        thresholds.encode_error_ratio
      )
      |> maybe_append_ratio_reason(
        "service_latency_p95_ratio",
        Map.get(snapshot, :service_latency_p95_ratio, 0.0),
        thresholds.service_latency_p95_ratio
      )
      |> maybe_append_ratio_reason(
        "retryable_error_budget_ratio",
        Map.get(snapshot, :retryable_error_budget_ratio, 0.0),
        thresholds.retryable_error_budget_ratio
      )
      |> maybe_append_count_reason(
        "joinability_failures",
        Map.get(snapshot, :joinability_failures, 0),
        thresholds.joinability_failures
      )

    case reasons do
      [] -> {:go, %{reasons: []}}
      _ -> {:rollback, %{reasons: reasons}}
    end
  end

  defp maybe_append_ratio_reason(reasons, signal_name, value, threshold)
       when is_list(reasons) and is_binary(signal_name) and is_number(value) and
              is_number(threshold) do
    if value > threshold do
      ["#{signal_name}=#{value} exceeded threshold #{threshold}" | reasons]
    else
      reasons
    end
  end

  defp maybe_append_count_reason(reasons, signal_name, value, threshold)
       when is_list(reasons) and is_binary(signal_name) and is_integer(value) and
              is_integer(threshold) do
    if value > threshold do
      ["#{signal_name}=#{value} exceeded threshold #{threshold}" | reasons]
    else
      reasons
    end
  end
end
