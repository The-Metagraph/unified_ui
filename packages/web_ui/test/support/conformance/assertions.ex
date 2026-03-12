defmodule WebUi.TestSupport.Conformance.Assertions do
  @moduledoc false

  import ExUnit.Assertions

  @spec assert_typed_error(map(), String.t(), String.t() | nil) :: :ok
  def assert_typed_error(error, expected_code, expected_category \\ nil) when is_binary(expected_code) do
    assert is_map(error)
    assert fetch_any(error, :error_code) == expected_code

    if is_binary(expected_category) do
      assert fetch_any(error, :category) == expected_category
    end

    :ok
  end

  @spec assert_correlation_continuity(map(), String.t(), String.t()) :: :ok
  def assert_correlation_continuity(surface, expected_correlation_id, expected_request_id)
      when is_binary(expected_correlation_id) and is_binary(expected_request_id) do
    assert is_map(surface)
    assert fetch_any(surface, :correlation_id) == expected_correlation_id
    assert fetch_any(surface, :request_id) == expected_request_id
    :ok
  end

  @spec assert_event_payload_keys(map(), [String.t() | atom()]) :: :ok
  def assert_event_payload_keys(payload, required_keys) when is_map(payload) and is_list(required_keys) do
    missing =
      required_keys
      |> Enum.map(&to_string/1)
      |> Enum.filter(fn key ->
        value = fetch_any(payload, key)
        value in [nil, ""]
      end)

    assert missing == []
    :ok
  end

  defp fetch_any(map, key) when is_map(map) and is_atom(key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
  defp fetch_any(map, key) when is_map(map) and is_binary(key), do: Map.get(map, key) || Map.get(map, safe_existing_atom(key))

  defp safe_existing_atom(value) when is_binary(value) do
    try do
      String.to_existing_atom(value)
    rescue
      ArgumentError -> nil
    end
  end
end
