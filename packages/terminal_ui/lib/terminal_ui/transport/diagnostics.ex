defmodule TerminalUi.Transport.Diagnostics do
  @moduledoc """
  Inspection and validation helpers for the `terminal_ui` transport layer.
  """

  alias Jido.Signal
  alias TerminalUi.Transport.{Error, Normalize}
  alias TerminalUi.Transport.Signal, as: TransportSignal

  @payload_leak_keys [:escape_sequence, :termcode, :ansi, :backend_payload, :terminal_bytes]
  @payload_leak_prefixes ["ansi_", "term_", "escape_", "csi_"]

  @spec mapping_summary() :: map()
  def mapping_summary do
    %{
      families: TransportSignal.families(),
      input_families: Normalize.input_families(),
      local_default_families: TransportSignal.local_default_families(),
      boundary_crossing_families: TransportSignal.boundary_crossing_families(),
      modes: TerminalUi.Transport.modes()
    }
  end

  @spec normalized_event_families() :: [atom()]
  def normalized_event_families, do: Normalize.input_families()

  @spec validate_native_event(keyword() | map()) :: :ok | {:error, Error.t()}
  def validate_native_event(attrs) when is_map(attrs) or is_list(attrs) do
    with {:ok, normalized} <- Normalize.normalize(attrs),
         :ok <- validate_payload(Map.get(normalized, :payload, %{}), :native_event) do
      if Map.get(normalized, :boundary) == :boundary do
        validate_boundary_context(normalized)
      else
        :ok
      end
    end
  end

  def validate_native_event(value), do: {:error, Error.invalid_native_event(value)}

  @spec validate_translation(map()) :: :ok | {:error, Error.t()}
  def validate_translation(%{} = translation) do
    with :ok <- validate_payload(Map.get(translation, :payload, %{}), :translation_payload),
         :ok <- validate_payload(Map.get(translation, :target, %{}), :translation_target),
         :ok <- maybe_validate_boundary_signal(translation) do
      if Map.get(translation, :boundary) == :boundary do
        validate_boundary_context(translation)
      else
        :ok
      end
    end
  end

  def validate_translation(value), do: {:error, Error.invalid_native_event(value)}

  @spec validate_boundary_signal(Signal.t() | map()) :: :ok | {:error, Error.t()}
  def validate_boundary_signal(%Signal{} = signal) do
    with {:ok, translation} <- TransportSignal.from_boundary_signal(signal),
         :ok <- validate_translation(translation) do
      :ok
    end
  end

  def validate_boundary_signal(%{signal: %Signal{} = signal}),
    do: validate_boundary_signal(signal)

  def validate_boundary_signal(attrs) when is_map(attrs) or is_list(attrs) do
    case Signal.new(attrs) do
      {:ok, signal} -> validate_boundary_signal(signal)
      {:error, _reason} -> {:error, Error.invalid_boundary_signal(attrs)}
    end
  end

  def validate_boundary_signal(value), do: {:error, Error.invalid_boundary_signal(value)}

  defp maybe_validate_boundary_signal(%{boundary: :boundary, signal: %Signal{} = signal}) do
    validate_signal_payload(signal)
  end

  defp maybe_validate_boundary_signal(%{boundary: :boundary}) do
    {:error, Error.invalid_boundary_signal(:missing_signal)}
  end

  defp maybe_validate_boundary_signal(_translation), do: :ok

  defp validate_signal_payload(%Signal{} = signal) do
    validate_payload(signal.data || %{}, :boundary_signal)
  end

  defp validate_payload(payload, _surface) when is_map(payload) do
    leaked_keys = leaked_keys(payload)

    if leaked_keys == [] do
      :ok
    else
      {:error, Error.leaked_backend_detail(leaked_keys)}
    end
  end

  defp validate_payload(nil, _surface), do: :ok

  defp validate_payload(payload, surface),
    do: {:error, Error.invalid_payload_mapping(payload, surface)}

  defp validate_boundary_context(translation) do
    missing =
      []
      |> maybe_missing(:screen, Map.get(translation, :screen))
      |> maybe_missing(
        :runtime_id_or_widget_id,
        if(is_nil(Map.get(translation, :runtime_id)) and is_nil(Map.get(translation, :widget_id)),
          do: nil,
          else: :ok
        )
      )

    if missing == [] do
      :ok
    else
      {:error, Error.missing_boundary_context(missing)}
    end
  end

  defp leaked_keys(map) when is_map(map) do
    map
    |> Map.keys()
    |> Enum.filter(&leaked_key?/1)
  end

  defp leaked_key?(key) when key in @payload_leak_keys, do: true
  defp leaked_key?(key) when is_atom(key), do: leaked_key?(Atom.to_string(key))

  defp leaked_key?(key) when is_binary(key) do
    Enum.any?(@payload_leak_prefixes, &String.starts_with?(key, &1))
  end

  defp leaked_key?(_key), do: false

  defp maybe_missing(fields, field, nil), do: fields ++ [field]
  defp maybe_missing(fields, field, ""), do: fields ++ [field]
  defp maybe_missing(fields, _field, _value), do: fields
end
