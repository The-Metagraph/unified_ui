defmodule WebUi.Persistence.ReplayLog do
  @moduledoc """
  Deterministic replay-log helpers for runtime dispatch and reconciliation traces.
  """

  alias WebUi.TypedError

  @export_format "web_ui.replay_log.export.v1"
  @baseline_format "web_ui.replay_baseline.v1"
  @checkpoint_width 6
  @baseline_width 6
  @hash_width 10

  @type entry :: %{
          cursor: non_neg_integer(),
          direction: :outbound | :inbound,
          event: String.t(),
          payload_fingerprint: non_neg_integer(),
          metadata: map()
        }

  @type t :: %{
          cursor: non_neg_integer(),
          entries: [entry()],
          last_checkpoint_id: String.t() | nil
        }

  @spec new() :: t()
  def new do
    %{cursor: 0, entries: [], last_checkpoint_id: nil}
  end

  @spec append(t(), map()) :: {:ok, t()} | {:error, TypedError.t()}
  def append(log, attrs) when is_map(log) and is_map(attrs) do
    with :ok <- validate_log(log),
         {:ok, direction} <- normalize_direction(Map.get(attrs, :direction), attrs),
         {:ok, event} <- normalize_event(Map.get(attrs, :event), attrs),
         {:ok, metadata} <- normalize_metadata(Map.get(attrs, :metadata), attrs) do
      next_cursor = Map.get(log, :cursor) + 1

      entry = %{
        cursor: next_cursor,
        direction: direction,
        event: event,
        payload_fingerprint: :erlang.phash2(metadata),
        metadata: metadata
      }

      entries = Map.get(log, :entries, []) ++ [entry]
      checkpoint_id = checkpoint_id(next_cursor, entries)

      {:ok,
       %{
         cursor: next_cursor,
         entries: entries,
         last_checkpoint_id: checkpoint_id
       }}
    end
  end

  def append(_log, attrs) do
    {:error,
     TypedError.new(
       "replay_log.invalid_log_state",
       "validation",
       false,
       %{reason: "log must be a map", attrs: attrs}
     )}
  end

  @spec cursor(t()) :: non_neg_integer()
  def cursor(log) when is_map(log) do
    case Map.get(log, :cursor) do
      value when is_integer(value) and value >= 0 -> value
      _ -> 0
    end
  end

  @spec entries(t()) :: [entry()]
  def entries(log) when is_map(log) do
    case Map.get(log, :entries) do
      value when is_list(value) -> value
      _ -> []
    end
  end

  @spec entries_since(t(), non_neg_integer()) :: [entry()]
  def entries_since(log, from_cursor)
      when is_map(log) and is_integer(from_cursor) and from_cursor >= 0 do
    log
    |> entries()
    |> Enum.filter(fn entry ->
      is_map(entry) and Map.get(entry, :cursor, 0) > from_cursor
    end)
  end

  @spec snapshot(t(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def snapshot(log, opts \\ %{})

  def snapshot(log, opts) when is_map(log) and is_map(opts) do
    with :ok <- validate_log(log),
         {:ok, from_cursor} <- normalize_from_cursor(Map.get(opts, :from_cursor, 0), opts),
         {:ok, limit} <- normalize_limit(Map.get(opts, :limit), opts) do
      entries =
        log
        |> entries_since(from_cursor)
        |> maybe_limit_entries(limit)

      {:ok,
       %{
         cursor: cursor(log),
         checkpoint_id: Map.get(log, :last_checkpoint_id),
         entry_count: length(entries),
         entries: entries
       }}
    end
  end

  def snapshot(_log, opts) do
    {:error,
     TypedError.new(
       "replay_log.invalid_log_state",
       "validation",
       false,
       %{reason: "log must be a map", opts: opts}
     )}
  end

  @spec compact(t(), map()) :: {:ok, t()} | {:error, TypedError.t()}
  def compact(log, opts) when is_map(log) and is_map(opts) do
    with :ok <- validate_log(log),
         {:ok, keep_last} <- normalize_keep_last(Map.get(opts, :keep_last), opts) do
      retained_entries =
        log
        |> entries()
        |> Enum.take(-keep_last)

      current_cursor = cursor(log)

      {:ok,
       %{
         cursor: current_cursor,
         entries: retained_entries,
         last_checkpoint_id: checkpoint_id(current_cursor, retained_entries)
       }}
    end
  end

  def compact(_log, opts) do
    {:error,
     TypedError.new(
       "replay_log.invalid_log_state",
       "validation",
       false,
       %{reason: "log must be a map", opts: opts}
     )}
  end

  @spec export(t()) :: {:ok, map()} | {:error, TypedError.t()}
  def export(log) when is_map(log) do
    with :ok <- validate_log(log) do
      checkpoint_id = restored_checkpoint_id(cursor(log), entries(log))

      {:ok,
       %{
         format: @export_format,
         cursor: cursor(log),
         checkpoint_id: checkpoint_id,
         entries: entries(log)
       }}
    end
  end

  def export(_log) do
    {:error,
     TypedError.new(
       "replay_log.invalid_log_state",
       "validation",
       false,
       %{reason: "log must be a map"}
     )}
  end

  @spec restore(map()) :: {:ok, t()} | {:error, TypedError.t()}
  def restore(payload) when is_map(payload) do
    with :ok <- validate_export_format(payload),
         {:ok, cursor} <- normalize_export_cursor(fetch_any(payload, :cursor), payload),
         {:ok, entries} <- normalize_export_entries(fetch_any(payload, :entries), payload),
         :ok <- validate_restored_entry_cursors(entries, cursor, payload),
         {:ok, checkpoint_id} <-
           normalize_export_checkpoint_id(fetch_any(payload, :checkpoint_id), payload),
         computed_checkpoint_id <- restored_checkpoint_id(cursor, entries),
         :ok <-
           validate_restored_checkpoint_match(
             checkpoint_id,
             computed_checkpoint_id,
             payload
           ) do
      {:ok, %{cursor: cursor, entries: entries, last_checkpoint_id: computed_checkpoint_id}}
    end
  end

  def restore(payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{reason: "restore payload must be a map", payload: payload}
     )}
  end

  @spec compare(t(), t()) :: {:ok, map()} | {:error, TypedError.t()}
  def compare(actual_log, expected_log) when is_map(actual_log) and is_map(expected_log) do
    with :ok <- validate_log(actual_log),
         :ok <- validate_log(expected_log) do
      actual_cursor = cursor(actual_log)
      expected_cursor = cursor(expected_log)
      actual_entries = entries(actual_log)
      expected_entries = entries(expected_log)
      actual_checkpoint_id = restored_checkpoint_id(actual_cursor, actual_entries)
      expected_checkpoint_id = restored_checkpoint_id(expected_cursor, expected_entries)
      first_drift = first_drift(actual_entries, expected_entries)

      status =
        if is_nil(first_drift) and actual_cursor == expected_cursor and
             actual_checkpoint_id == expected_checkpoint_id do
          "match"
        else
          "drift"
        end

      {:ok,
       %{
         status: status,
         actual_cursor: actual_cursor,
         expected_cursor: expected_cursor,
         actual_entry_count: length(actual_entries),
         expected_entry_count: length(expected_entries),
         actual_checkpoint_id: actual_checkpoint_id,
         expected_checkpoint_id: expected_checkpoint_id,
         first_drift: first_drift
       }}
    end
  end

  def compare(actual_log, expected_log) do
    {:error,
     TypedError.new(
       "replay_log.invalid_log_state",
       "validation",
       false,
       %{reason: "both logs must be maps", actual_log: actual_log, expected_log: expected_log}
     )}
  end

  @spec verify_export(t(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def verify_export(actual_log, expected_export_payload)
      when is_map(actual_log) and is_map(expected_export_payload) do
    with {:ok, expected_log} <- restore(expected_export_payload),
         {:ok, comparison} <- compare(actual_log, expected_log) do
      {:ok, Map.put(comparison, :expected_source, "export")}
    end
  end

  def verify_export(actual_log, expected_export_payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{
         reason: "expected export payload must be a map",
         actual_log: actual_log,
         expected_export_payload: expected_export_payload
       }
     )}
  end

  @spec gate_export(t(), map(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def gate_export(actual_log, expected_export_payload, policy \\ %{})

  def gate_export(actual_log, expected_export_payload, policy)
      when is_map(actual_log) and is_map(expected_export_payload) and is_map(policy) do
    with {:ok, verification} <- verify_export(actual_log, expected_export_payload),
         {:ok, normalized_policy} <- normalize_verification_policy(policy) do
      cursor_delta = abs(verification.actual_cursor - verification.expected_cursor)
      entry_count_delta = abs(verification.actual_entry_count - verification.expected_entry_count)
      reasons = gate_reasons(verification, normalized_policy, cursor_delta, entry_count_delta)
      status = if reasons == [], do: "pass", else: "fail"

      {:ok,
       %{
         status: status,
         reasons: reasons,
         cursor_delta: cursor_delta,
         entry_count_delta: entry_count_delta,
         policy: normalized_policy,
         verification: verification
       }}
    end
  end

  def gate_export(actual_log, expected_export_payload, policy) do
    {:error,
     TypedError.new(
       "replay_log.invalid_verification_policy",
       "validation",
       false,
       %{
         reason: "actual log, expected export payload, and policy must be maps",
         actual_log: actual_log,
         expected_export_payload: expected_export_payload,
         policy: policy
       }
     )}
  end

  @spec capture_baseline(t(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def capture_baseline(log, metadata \\ %{})

  def capture_baseline(log, metadata) when is_map(log) and is_map(metadata) do
    with :ok <- validate_log(log),
         {:ok, export_payload} <- export(log) do
      baseline_cursor = cursor(log)
      baseline_entries = entries(log)
      checkpoint_id = restored_checkpoint_id(baseline_cursor, baseline_entries)
      baseline_id = baseline_id(baseline_cursor, checkpoint_id)

      {:ok,
       %{
         format: @baseline_format,
         baseline_id: baseline_id,
         cursor: baseline_cursor,
         checkpoint_id: checkpoint_id,
         entry_count: length(baseline_entries),
         export: export_payload,
         metadata: metadata
       }}
    end
  end

  def capture_baseline(log, metadata) do
    {:error,
     TypedError.new(
       "replay_log.invalid_baseline_payload",
       "validation",
       false,
       %{reason: "log and metadata must be maps", log: log, metadata: metadata}
     )}
  end

  @spec gate_baseline(t(), map(), map()) :: {:ok, map()} | {:error, TypedError.t()}
  def gate_baseline(actual_log, baseline, policy \\ %{})

  def gate_baseline(actual_log, baseline, policy)
      when is_map(actual_log) and is_map(baseline) and is_map(policy) do
    with {:ok, baseline_export, baseline_summary} <- normalize_baseline_payload(baseline),
         {:ok, gate} <- gate_export(actual_log, baseline_export, policy) do
      {:ok,
       %{
         status: gate.status,
         baseline: baseline_summary,
         gate: gate
       }}
    end
  end

  def gate_baseline(actual_log, baseline, policy) do
    {:error,
     TypedError.new(
       "replay_log.invalid_baseline_payload",
       "validation",
       false,
       %{
         reason: "actual log, baseline, and policy must be maps",
         actual_log: actual_log,
         baseline: baseline,
         policy: policy
       }
     )}
  end

  @spec checkpoint(t()) :: %{cursor: non_neg_integer(), checkpoint_id: String.t() | nil}
  def checkpoint(log) when is_map(log) do
    %{
      cursor: cursor(log),
      checkpoint_id: Map.get(log, :last_checkpoint_id)
    }
  end

  defp validate_log(log) when is_map(log) do
    cond do
      not is_integer(Map.get(log, :cursor)) ->
        invalid_log_error(log, "cursor must be a non-negative integer")

      Map.get(log, :cursor) < 0 ->
        invalid_log_error(log, "cursor must be a non-negative integer")

      not is_list(Map.get(log, :entries)) ->
        invalid_log_error(log, "entries must be a list")

      true ->
        :ok
    end
  end

  defp normalize_direction(direction, _attrs) when direction in [:outbound, :inbound],
    do: {:ok, direction}

  defp normalize_direction(direction, attrs) do
    {:error,
     TypedError.new(
       "replay_log.invalid_entry_shape",
       "validation",
       false,
       %{reason: "direction must be :outbound or :inbound", direction: direction, attrs: attrs}
     )}
  end

  defp normalize_event(event, _attrs) when is_atom(event), do: {:ok, Atom.to_string(event)}

  defp normalize_event(event, _attrs) when is_binary(event) and event != "" do
    {:ok, event}
  end

  defp normalize_event(event, attrs) do
    {:error,
     TypedError.new(
       "replay_log.invalid_entry_shape",
       "validation",
       false,
       %{reason: "event must be a non-empty string or atom", event: event, attrs: attrs}
     )}
  end

  defp normalize_metadata(nil, _attrs), do: {:ok, %{}}
  defp normalize_metadata(metadata, _attrs) when is_map(metadata), do: {:ok, metadata}

  defp normalize_metadata(metadata, attrs) do
    {:error,
     TypedError.new(
       "replay_log.invalid_entry_shape",
       "validation",
       false,
       %{reason: "metadata must be a map", metadata: metadata, attrs: attrs}
     )}
  end

  defp normalize_from_cursor(from_cursor, _opts)
       when is_integer(from_cursor) and from_cursor >= 0,
       do: {:ok, from_cursor}

  defp normalize_from_cursor(from_cursor, opts) do
    {:error,
     TypedError.new(
       "replay_log.invalid_snapshot_options",
       "validation",
       false,
       %{
         reason: "from_cursor must be a non-negative integer",
         from_cursor: from_cursor,
         opts: opts
       }
     )}
  end

  defp normalize_limit(nil, _opts), do: {:ok, nil}
  defp normalize_limit(limit, _opts) when is_integer(limit) and limit >= 0, do: {:ok, limit}

  defp normalize_limit(limit, opts) do
    {:error,
     TypedError.new(
       "replay_log.invalid_snapshot_options",
       "validation",
       false,
       %{reason: "limit must be a non-negative integer when provided", limit: limit, opts: opts}
     )}
  end

  defp normalize_keep_last(keep_last, _opts)
       when is_integer(keep_last) and keep_last >= 0,
       do: {:ok, keep_last}

  defp normalize_keep_last(keep_last, opts) do
    {:error,
     TypedError.new(
       "replay_log.invalid_compaction_options",
       "validation",
       false,
       %{reason: "keep_last must be a non-negative integer", keep_last: keep_last, opts: opts}
     )}
  end

  defp maybe_limit_entries(entries, nil) when is_list(entries), do: entries
  defp maybe_limit_entries(_entries, 0), do: []

  defp maybe_limit_entries(entries, limit) when is_list(entries) and is_integer(limit),
    do: Enum.take(entries, limit)

  defp validate_export_format(payload) when is_map(payload) do
    case fetch_any(payload, :format) do
      @export_format ->
        :ok

      format ->
        {:error,
         TypedError.new(
           "replay_log.invalid_export_format",
           "validation",
           false,
           %{reason: "unsupported replay export format", format: format, payload: payload}
         )}
    end
  end

  defp normalize_export_cursor(cursor, _payload) when is_integer(cursor) and cursor >= 0,
    do: {:ok, cursor}

  defp normalize_export_cursor(cursor, payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{reason: "cursor must be a non-negative integer", cursor: cursor, payload: payload}
     )}
  end

  defp normalize_export_entries(entries, payload) when is_list(entries) do
    entries
    |> Enum.with_index()
    |> Enum.reduce_while({:ok, []}, fn {entry, index}, {:ok, acc} ->
      case normalize_export_entry(entry, index, payload) do
        {:ok, normalized_entry} -> {:cont, {:ok, acc ++ [normalized_entry]}}
        {:error, _error} = error -> {:halt, error}
      end
    end)
  end

  defp normalize_export_entries(entries, payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{reason: "entries must be a list", entries: entries, payload: payload}
     )}
  end

  defp normalize_export_entry(entry, index, payload) when is_map(entry) do
    cursor = fetch_any(entry, :cursor)
    direction = fetch_any(entry, :direction)
    event = fetch_any(entry, :event)
    metadata = fetch_any(entry, :metadata)
    fingerprint = fetch_any(entry, :payload_fingerprint)

    with {:ok, normalized_cursor} <- normalize_export_entry_cursor(cursor, index, payload),
         {:ok, normalized_direction} <-
           normalize_export_entry_direction(direction, index, payload),
         {:ok, normalized_event} <- normalize_export_entry_event(event, index, payload),
         {:ok, normalized_metadata} <- normalize_export_entry_metadata(metadata, index, payload),
         {:ok, normalized_fingerprint} <-
           normalize_export_entry_fingerprint(fingerprint, normalized_metadata) do
      {:ok,
       %{
         cursor: normalized_cursor,
         direction: normalized_direction,
         event: normalized_event,
         payload_fingerprint: normalized_fingerprint,
         metadata: normalized_metadata
       }}
    end
  end

  defp normalize_export_entry(entry, index, payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{
         reason: "entries must contain maps",
         entry_index: index,
         entry: entry,
         payload: payload
       }
     )}
  end

  defp normalize_export_entry_cursor(cursor, _index, _payload)
       when is_integer(cursor) and cursor >= 1,
       do: {:ok, cursor}

  defp normalize_export_entry_cursor(cursor, index, payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{
         reason: "entry cursor must be a positive integer",
         entry_index: index,
         cursor: cursor,
         payload: payload
       }
     )}
  end

  defp normalize_export_entry_direction(direction, _index, _payload)
       when direction in [:outbound, :inbound],
       do: {:ok, direction}

  defp normalize_export_entry_direction("outbound", _index, _payload), do: {:ok, :outbound}
  defp normalize_export_entry_direction("inbound", _index, _payload), do: {:ok, :inbound}

  defp normalize_export_entry_direction(direction, index, payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{
         reason: "entry direction must be outbound or inbound",
         entry_index: index,
         direction: direction,
         payload: payload
       }
     )}
  end

  defp normalize_export_entry_event(event, _index, _payload) when is_atom(event),
    do: {:ok, Atom.to_string(event)}

  defp normalize_export_entry_event(event, _index, _payload)
       when is_binary(event) and event != "",
       do: {:ok, event}

  defp normalize_export_entry_event(event, index, payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{
         reason: "entry event must be a non-empty string or atom",
         entry_index: index,
         event: event,
         payload: payload
       }
     )}
  end

  defp normalize_export_entry_metadata(metadata, _index, _payload) when is_map(metadata),
    do: {:ok, metadata}

  defp normalize_export_entry_metadata(metadata, index, payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{
         reason: "entry metadata must be a map",
         entry_index: index,
         metadata: metadata,
         payload: payload
       }
     )}
  end

  defp normalize_export_entry_fingerprint(fingerprint, _metadata)
       when is_integer(fingerprint) and fingerprint >= 0,
       do: {:ok, fingerprint}

  defp normalize_export_entry_fingerprint(nil, metadata) when is_map(metadata),
    do: {:ok, :erlang.phash2(metadata)}

  defp normalize_export_entry_fingerprint(_fingerprint, metadata) when is_map(metadata),
    do: {:ok, :erlang.phash2(metadata)}

  defp validate_restored_entry_cursors([], cursor, payload)
       when is_integer(cursor) and cursor >= 0 do
    if cursor == 0 do
      :ok
    else
      {:error,
       TypedError.new(
         "replay_log.invalid_restore_payload",
         "validation",
         false,
         %{reason: "cursor must be 0 when entries are empty", cursor: cursor, payload: payload}
       )}
    end
  end

  defp validate_restored_entry_cursors(entries, cursor, payload)
       when is_list(entries) and is_integer(cursor) do
    entry_cursors = Enum.map(entries, &Map.get(&1, :cursor))

    cond do
      entry_cursors != Enum.sort(entry_cursors) ->
        {:error,
         TypedError.new(
           "replay_log.invalid_restore_payload",
           "validation",
           false,
           %{
             reason: "entry cursors must be ascending",
             entry_cursors: entry_cursors,
             payload: payload
           }
         )}

      length(entry_cursors) != length(Enum.uniq(entry_cursors)) ->
        {:error,
         TypedError.new(
           "replay_log.invalid_restore_payload",
           "validation",
           false,
           %{
             reason: "entry cursors must be unique",
             entry_cursors: entry_cursors,
             payload: payload
           }
         )}

      List.last(entry_cursors) != cursor ->
        {:error,
         TypedError.new(
           "replay_log.invalid_restore_payload",
           "validation",
           false,
           %{
             reason: "cursor must match the last entry cursor",
             cursor: cursor,
             entry_cursors: entry_cursors,
             payload: payload
           }
         )}

      true ->
        :ok
    end
  end

  defp normalize_export_checkpoint_id(nil, _payload), do: {:ok, nil}

  defp normalize_export_checkpoint_id(checkpoint_id, _payload) when is_binary(checkpoint_id),
    do: {:ok, checkpoint_id}

  defp normalize_export_checkpoint_id(checkpoint_id, payload) do
    {:error,
     TypedError.new(
       "replay_log.invalid_restore_payload",
       "validation",
       false,
       %{
         reason: "checkpoint_id must be a string or nil",
         checkpoint_id: checkpoint_id,
         payload: payload
       }
     )}
  end

  defp validate_restored_checkpoint_match(exported_checkpoint_id, computed_checkpoint_id, payload) do
    if exported_checkpoint_id == computed_checkpoint_id do
      :ok
    else
      {:error,
       TypedError.new(
         "replay_log.restore_checkpoint_mismatch",
         "validation",
         false,
         %{
           reason: "checkpoint_id does not match replay entries",
           exported_checkpoint_id: exported_checkpoint_id,
           computed_checkpoint_id: computed_checkpoint_id,
           payload: payload
         }
       )}
    end
  end

  defp restored_checkpoint_id(0, []), do: nil
  defp restored_checkpoint_id(cursor, entries), do: checkpoint_id(cursor, entries)

  defp first_drift(actual_entries, expected_entries)
       when is_list(actual_entries) and is_list(expected_entries) do
    normalized_actual = Enum.map(actual_entries, &normalized_entry/1)
    normalized_expected = Enum.map(expected_entries, &normalized_entry/1)

    case first_entry_mismatch(normalized_actual, normalized_expected) do
      {:mismatch, index, actual_entry, expected_entry} ->
        %{
          reason: "entry_mismatch",
          index: index,
          cursor:
            mismatch_cursor(actual_entry, expected_entry, normalized_actual, normalized_expected),
          actual_entry: actual_entry,
          expected_entry: expected_entry
        }

      :none ->
        if length(normalized_actual) == length(normalized_expected) do
          nil
        else
          %{
            reason: "entry_count_mismatch",
            index: min(length(normalized_actual), length(normalized_expected)),
            cursor: trailing_cursor(normalized_actual, normalized_expected),
            actual_entry_count: length(normalized_actual),
            expected_entry_count: length(normalized_expected)
          }
        end
    end
  end

  defp normalized_entry(entry) when is_map(entry) do
    %{
      cursor: fetch_any(entry, :cursor),
      direction: fetch_any(entry, :direction),
      event: normalize_entry_event(fetch_any(entry, :event)),
      payload_fingerprint: fetch_any(entry, :payload_fingerprint),
      metadata: fetch_any(entry, :metadata)
    }
  end

  defp first_entry_mismatch(actual_entries, expected_entries)
       when is_list(actual_entries) and is_list(expected_entries) do
    actual_entries
    |> Enum.zip(expected_entries)
    |> Enum.with_index()
    |> Enum.reduce_while(:none, fn {{actual_entry, expected_entry}, index}, _acc ->
      if actual_entry == expected_entry do
        {:cont, :none}
      else
        {:halt, {:mismatch, index, actual_entry, expected_entry}}
      end
    end)
  end

  defp mismatch_cursor(actual_entry, expected_entry, _actual_entries, _expected_entries)
       when is_map(actual_entry) and is_map(expected_entry) do
    fetch_any(actual_entry, :cursor) || fetch_any(expected_entry, :cursor)
  end

  defp mismatch_cursor(_actual_entry, _expected_entry, actual_entries, expected_entries) do
    trailing_cursor(actual_entries, expected_entries)
  end

  defp trailing_cursor(actual_entries, expected_entries)
       when is_list(actual_entries) and is_list(expected_entries) do
    case length(actual_entries) > length(expected_entries) do
      true ->
        actual_entries
        |> Enum.at(length(expected_entries))
        |> fetch_any(:cursor)

      false ->
        expected_entries
        |> Enum.at(length(actual_entries))
        |> fetch_any(:cursor)
    end
  end

  defp normalize_entry_event(event) when is_atom(event), do: Atom.to_string(event)
  defp normalize_entry_event(event), do: event

  defp normalize_verification_policy(policy) when is_map(policy) do
    with {:ok, allowed_statuses} <-
           normalize_allowed_statuses(fetch_any(policy, :allowed_statuses), policy),
         {:ok, max_cursor_delta} <-
           normalize_policy_non_neg_integer(
             fetch_any(policy, :max_cursor_delta),
             0,
             "max_cursor_delta",
             policy
           ),
         {:ok, max_entry_count_delta} <-
           normalize_policy_non_neg_integer(
             fetch_any(policy, :max_entry_count_delta),
             0,
             "max_entry_count_delta",
             policy
           ),
         {:ok, allow_entry_mismatch} <-
           normalize_policy_boolean(
             fetch_any(policy, :allow_entry_mismatch),
             false,
             "allow_entry_mismatch",
             policy
           ) do
      {:ok,
       %{
         allowed_statuses: allowed_statuses,
         max_cursor_delta: max_cursor_delta,
         max_entry_count_delta: max_entry_count_delta,
         allow_entry_mismatch: allow_entry_mismatch
       }}
    end
  end

  defp normalize_verification_policy(policy) do
    {:error,
     TypedError.new(
       "replay_log.invalid_verification_policy",
       "validation",
       false,
       %{reason: "policy must be a map", policy: policy}
     )}
  end

  defp normalize_allowed_statuses(nil, _policy), do: {:ok, ["match"]}

  defp normalize_allowed_statuses(statuses, policy) when is_list(statuses) do
    normalized =
      statuses
      |> Enum.map(&normalize_status/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    cond do
      normalized == [] ->
        {:error,
         TypedError.new(
           "replay_log.invalid_verification_policy",
           "validation",
           false,
           %{reason: "allowed_statuses must include match and/or drift", policy: policy}
         )}

      Enum.all?(normalized, &(&1 in ["match", "drift"])) ->
        {:ok, normalized}

      true ->
        {:error,
         TypedError.new(
           "replay_log.invalid_verification_policy",
           "validation",
           false,
           %{reason: "allowed_statuses must include match and/or drift", policy: policy}
         )}
    end
  end

  defp normalize_allowed_statuses(_statuses, policy) do
    {:error,
     TypedError.new(
       "replay_log.invalid_verification_policy",
       "validation",
       false,
       %{reason: "allowed_statuses must be a list", policy: policy}
     )}
  end

  defp normalize_policy_non_neg_integer(nil, default, _field, _policy), do: {:ok, default}

  defp normalize_policy_non_neg_integer(value, _default, _field, _policy)
       when is_integer(value) and value >= 0,
       do: {:ok, value}

  defp normalize_policy_non_neg_integer(value, _default, field, policy) do
    {:error,
     TypedError.new(
       "replay_log.invalid_verification_policy",
       "validation",
       false,
       %{reason: "#{field} must be a non-negative integer", value: value, policy: policy}
     )}
  end

  defp normalize_policy_boolean(nil, default, _field, _policy), do: {:ok, default}

  defp normalize_policy_boolean(value, _default, _field, _policy) when is_boolean(value),
    do: {:ok, value}

  defp normalize_policy_boolean(value, _default, field, policy) do
    {:error,
     TypedError.new(
       "replay_log.invalid_verification_policy",
       "validation",
       false,
       %{reason: "#{field} must be a boolean", value: value, policy: policy}
     )}
  end

  defp gate_reasons(verification, policy, cursor_delta, entry_count_delta)
       when is_map(verification) and is_map(policy) do
    []
    |> maybe_add_status_reason(verification, policy)
    |> maybe_add_cursor_delta_reason(cursor_delta, policy)
    |> maybe_add_entry_count_delta_reason(entry_count_delta, policy)
    |> maybe_add_entry_mismatch_reason(verification, policy)
  end

  defp maybe_add_status_reason(reasons, verification, policy)
       when is_list(reasons) and is_map(verification) and is_map(policy) do
    status = fetch_any(verification, :status)
    allowed_statuses = fetch_any(policy, :allowed_statuses) || []

    if status in allowed_statuses do
      reasons
    else
      reasons ++
        [
          %{
            code: "status_not_allowed",
            status: status,
            allowed_statuses: allowed_statuses
          }
        ]
    end
  end

  defp maybe_add_cursor_delta_reason(reasons, cursor_delta, policy)
       when is_list(reasons) and is_integer(cursor_delta) and is_map(policy) do
    max_cursor_delta = fetch_any(policy, :max_cursor_delta) || 0

    if cursor_delta <= max_cursor_delta do
      reasons
    else
      reasons ++
        [
          %{
            code: "cursor_delta_exceeded",
            cursor_delta: cursor_delta,
            max_cursor_delta: max_cursor_delta
          }
        ]
    end
  end

  defp maybe_add_entry_count_delta_reason(reasons, entry_count_delta, policy)
       when is_list(reasons) and is_integer(entry_count_delta) and is_map(policy) do
    max_entry_count_delta = fetch_any(policy, :max_entry_count_delta) || 0

    if entry_count_delta <= max_entry_count_delta do
      reasons
    else
      reasons ++
        [
          %{
            code: "entry_count_delta_exceeded",
            entry_count_delta: entry_count_delta,
            max_entry_count_delta: max_entry_count_delta
          }
        ]
    end
  end

  defp maybe_add_entry_mismatch_reason(reasons, verification, policy)
       when is_list(reasons) and is_map(verification) and is_map(policy) do
    allow_entry_mismatch = fetch_any(policy, :allow_entry_mismatch) || false
    first_drift = fetch_any(verification, :first_drift)

    if allow_entry_mismatch || not entry_mismatch?(first_drift) do
      reasons
    else
      reasons ++ [%{code: "entry_mismatch_not_allowed", first_drift: first_drift}]
    end
  end

  defp entry_mismatch?(first_drift) when is_map(first_drift) do
    fetch_any(first_drift, :reason) == "entry_mismatch"
  end

  defp entry_mismatch?(_first_drift), do: false

  defp normalize_status(value) when is_binary(value) do
    case String.downcase(value) do
      "match" -> "match"
      "drift" -> "drift"
      _ -> nil
    end
  end

  defp normalize_status(value) when is_atom(value),
    do: value |> Atom.to_string() |> normalize_status()

  defp normalize_status(_value), do: nil

  defp normalize_baseline_payload(baseline) when is_map(baseline) do
    with :ok <- validate_baseline_format(baseline),
         {:ok, baseline_cursor} <-
           normalize_export_cursor(fetch_any(baseline, :cursor), baseline),
         {:ok, baseline_checkpoint_id} <-
           normalize_export_checkpoint_id(fetch_any(baseline, :checkpoint_id), baseline),
         {:ok, baseline_id} <-
           normalize_baseline_id(
             fetch_any(baseline, :baseline_id),
             baseline_cursor,
             baseline_checkpoint_id,
             baseline
           ),
         {:ok, baseline_entry_count} <-
           normalize_baseline_entry_count(fetch_any(baseline, :entry_count), baseline),
         {:ok, baseline_metadata} <-
           normalize_baseline_metadata(fetch_any(baseline, :metadata), baseline),
         {:ok, export_payload} <-
           normalize_baseline_export(fetch_any(baseline, :export), baseline),
         {:ok, export_log} <- restore(export_payload),
         :ok <-
           validate_baseline_export_alignment(
             baseline_cursor,
             baseline_checkpoint_id,
             baseline_entry_count,
             export_log,
             baseline
           ) do
      {:ok, export_payload,
       %{
         baseline_id: baseline_id,
         cursor: baseline_cursor,
         checkpoint_id: baseline_checkpoint_id,
         entry_count: baseline_entry_count,
         metadata: baseline_metadata
       }}
    end
  end

  defp normalize_baseline_payload(baseline) do
    {:error,
     TypedError.new(
       "replay_log.invalid_baseline_payload",
       "validation",
       false,
       %{reason: "baseline must be a map", baseline: baseline}
     )}
  end

  defp validate_baseline_format(baseline) when is_map(baseline) do
    case fetch_any(baseline, :format) do
      @baseline_format ->
        :ok

      format ->
        {:error,
         TypedError.new(
           "replay_log.invalid_baseline_format",
           "validation",
           false,
           %{reason: "unsupported replay baseline format", format: format, baseline: baseline}
         )}
    end
  end

  defp normalize_baseline_entry_count(entry_count, _baseline)
       when is_integer(entry_count) and entry_count >= 0,
       do: {:ok, entry_count}

  defp normalize_baseline_entry_count(entry_count, baseline) do
    {:error,
     TypedError.new(
       "replay_log.invalid_baseline_payload",
       "validation",
       false,
       %{
         reason: "entry_count must be a non-negative integer",
         entry_count: entry_count,
         baseline: baseline
       }
     )}
  end

  defp normalize_baseline_id(nil, baseline_cursor, baseline_checkpoint_id, _baseline)
       when is_integer(baseline_cursor) do
    {:ok, baseline_id(baseline_cursor, baseline_checkpoint_id)}
  end

  defp normalize_baseline_id(
         baseline_id,
         baseline_cursor,
         baseline_checkpoint_id,
         baseline
       )
       when is_binary(baseline_id) do
    expected_baseline_id = baseline_id(baseline_cursor, baseline_checkpoint_id)

    cond do
      baseline_id == "" ->
        {:error,
         TypedError.new(
           "replay_log.invalid_baseline_payload",
           "validation",
           false,
           %{reason: "baseline_id must be a non-empty string", baseline: baseline}
         )}

      baseline_id == expected_baseline_id ->
        {:ok, baseline_id}

      true ->
        {:error,
         TypedError.new(
           "replay_log.baseline_export_mismatch",
           "validation",
           false,
           %{
             reason: "baseline_id does not match deterministic replay baseline identity",
             baseline_id: baseline_id,
             expected_baseline_id: expected_baseline_id,
             baseline: baseline
           }
         )}
    end
  end

  defp normalize_baseline_id(baseline_id, _baseline_cursor, _baseline_checkpoint_id, baseline) do
    {:error,
     TypedError.new(
       "replay_log.invalid_baseline_payload",
       "validation",
       false,
       %{
         reason: "baseline_id must be a string when provided",
         baseline_id: baseline_id,
         baseline: baseline
       }
     )}
  end

  defp normalize_baseline_metadata(nil, _baseline), do: {:ok, %{}}
  defp normalize_baseline_metadata(metadata, _baseline) when is_map(metadata), do: {:ok, metadata}

  defp normalize_baseline_metadata(metadata, baseline) do
    {:error,
     TypedError.new(
       "replay_log.invalid_baseline_payload",
       "validation",
       false,
       %{reason: "metadata must be a map when provided", metadata: metadata, baseline: baseline}
     )}
  end

  defp normalize_baseline_export(export_payload, _baseline) when is_map(export_payload),
    do: {:ok, export_payload}

  defp normalize_baseline_export(export_payload, baseline) do
    {:error,
     TypedError.new(
       "replay_log.invalid_baseline_payload",
       "validation",
       false,
       %{reason: "baseline export must be a map", export: export_payload, baseline: baseline}
     )}
  end

  defp validate_baseline_export_alignment(
         baseline_cursor,
         baseline_checkpoint_id,
         baseline_entry_count,
         export_log,
         baseline
       )
       when is_integer(baseline_cursor) and is_integer(baseline_entry_count) and
              is_map(export_log) do
    export_cursor = cursor(export_log)
    export_checkpoint_id = restored_checkpoint_id(export_cursor, entries(export_log))
    export_entry_count = length(entries(export_log))

    cond do
      baseline_cursor != export_cursor ->
        {:error,
         TypedError.new(
           "replay_log.baseline_export_mismatch",
           "validation",
           false,
           %{
             reason: "baseline cursor does not match baseline export cursor",
             baseline_cursor: baseline_cursor,
             export_cursor: export_cursor,
             baseline: baseline
           }
         )}

      baseline_checkpoint_id != export_checkpoint_id ->
        {:error,
         TypedError.new(
           "replay_log.baseline_export_mismatch",
           "validation",
           false,
           %{
             reason: "baseline checkpoint does not match baseline export checkpoint",
             baseline_checkpoint_id: baseline_checkpoint_id,
             export_checkpoint_id: export_checkpoint_id,
             baseline: baseline
           }
         )}

      baseline_entry_count != export_entry_count ->
        {:error,
         TypedError.new(
           "replay_log.baseline_export_mismatch",
           "validation",
           false,
           %{
             reason: "baseline entry_count does not match baseline export entries",
             baseline_entry_count: baseline_entry_count,
             export_entry_count: export_entry_count,
             baseline: baseline
           }
         )}

      true ->
        :ok
    end
  end

  defp fetch_any(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp baseline_id(cursor, checkpoint_id)
       when is_integer(cursor) and cursor >= 0 do
    cursor_part =
      cursor
      |> Integer.to_string()
      |> String.pad_leading(@baseline_width, "0")

    hash_part =
      {cursor, checkpoint_id}
      |> :erlang.phash2()
      |> Integer.to_string()
      |> String.pad_leading(@hash_width, "0")

    "baseline-" <> cursor_part <> "-" <> hash_part
  end

  defp checkpoint_id(cursor, entries)
       when is_integer(cursor) and cursor >= 0 and is_list(entries) do
    cursor_part =
      cursor
      |> Integer.to_string()
      |> String.pad_leading(@checkpoint_width, "0")

    hash_part =
      entries
      |> :erlang.phash2()
      |> Integer.to_string()
      |> String.pad_leading(@hash_width, "0")

    "replay-" <> cursor_part <> "-" <> hash_part
  end

  defp invalid_log_error(log, reason) do
    {:error,
     TypedError.new(
       "replay_log.invalid_log_state",
       "validation",
       false,
       %{reason: reason, log: log}
     )}
  end
end
