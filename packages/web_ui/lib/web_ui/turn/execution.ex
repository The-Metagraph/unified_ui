defmodule WebUi.Turn.Execution do
  @moduledoc """
  Deterministic turn-execution helpers for runtime dispatch/reconciliation flows.
  """

  @turn_id_width 6

  @spec turn_id(non_neg_integer()) :: String.t()
  def turn_id(sequence) when is_integer(sequence) and sequence >= 0 do
    "turn-" <> (sequence |> Integer.to_string() |> String.pad_leading(@turn_id_width, "0"))
  end

  @spec turn_metadata(non_neg_integer()) :: %{
          turn_id: String.t(),
          dispatch_sequence: non_neg_integer()
        }
  def turn_metadata(sequence) when is_integer(sequence) and sequence >= 0 do
    %{
      turn_id: turn_id(sequence),
      dispatch_sequence: sequence
    }
  end

  @spec attach_turn_metadata(map(), non_neg_integer()) :: map()
  def attach_turn_metadata(data, sequence)
      when is_map(data) and is_integer(sequence) and sequence >= 0 do
    metadata = turn_metadata(sequence)

    data
    |> Map.put("dispatch_sequence", metadata.dispatch_sequence)
    |> Map.put("turn_id", metadata.turn_id)
  end

  @spec begin_turn(map(), non_neg_integer()) :: map()
  def begin_turn(slice_state, sequence)
      when is_map(slice_state) and is_integer(sequence) and sequence >= 0 do
    metadata = turn_metadata(sequence)

    slice_state
    |> Map.put(:dispatch_sequence, metadata.dispatch_sequence)
    |> Map.put(:active_turn_id, metadata.turn_id)
  end

  @spec complete_turn(map(), map()) :: map()
  def complete_turn(slice_state, result) when is_map(slice_state) and is_map(result) do
    completed_turn_id = Map.get(slice_state, :active_turn_id) || extract_turn_id(result)

    slice_state
    |> Map.put(:active_turn_id, nil)
    |> maybe_put_last_completed_turn_id(completed_turn_id)
  end

  @spec extract_turn_id(map()) :: String.t() | nil
  def extract_turn_id(result) when is_map(result) do
    payload = fetch_map(result, :payload)
    context = fetch_map(result, :context)
    ui_patch = fetch_map(payload, :ui_patch)

    fetch_string(payload, :turn_id) ||
      fetch_string(context, :turn_id) ||
      fetch_string(ui_patch, :turn_id)
  end

  def extract_turn_id(_), do: nil

  defp maybe_put_last_completed_turn_id(slice_state, turn_id)
       when is_binary(turn_id) and turn_id != "" do
    Map.put(slice_state, :last_completed_turn_id, turn_id)
  end

  defp maybe_put_last_completed_turn_id(slice_state, _turn_id), do: slice_state

  defp fetch_any(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp fetch_map(map, key) when is_map(map) do
    case fetch_any(map, key) do
      value when is_map(value) -> value
      _ -> %{}
    end
  end

  defp fetch_string(map, key) when is_map(map) do
    case fetch_any(map, key) do
      value when is_binary(value) and value != "" -> value
      _ -> nil
    end
  end
end
