defmodule LiveUi.Signals.Encoder do
  @moduledoc """
  Normalizes LiveView payloads into concrete `%Jido.Signal{}` structs.
  """

  alias Jido.Signal
  alias LiveUi.ConfigurationError

  @spec encode(String.t() | atom(), map(), map()) ::
          {:ok, Signal.t()} | {:error, ConfigurationError.t()}
  def encode(event_name, payload, runtime_context \\ %{})

  def encode(event_name, payload, runtime_context)
      when is_map(payload) and is_map(runtime_context) do
    {:ok, normalize_signal(event_name, payload, runtime_context)}
  rescue
    error in ConfigurationError -> {:error, error}
  end

  def encode(_event_name, _payload, _runtime_context) do
    {:error, ConfigurationError.new("live_ui event payload must be a map")}
  end

  defp normalize_signal(_event_name, %{"signal" => %Signal{} = signal}, _runtime_context),
    do: signal

  defp normalize_signal(_event_name, %{signal: %Signal{} = signal}, _runtime_context), do: signal

  defp normalize_signal(_event_name, %{"signal" => signal}, _runtime_context) do
    raise ConfigurationError.new("live_ui event payload signal must be a Jido.Signal struct", %{
            signal: inspect(signal)
          })
  end

  defp normalize_signal(_event_name, %{signal: signal}, _runtime_context) do
    raise ConfigurationError.new("live_ui event payload signal must be a Jido.Signal struct", %{
            signal: inspect(signal)
          })
  end

  defp normalize_signal(event_name, payload, runtime_context) do
    widget_id = required_payload_value(payload, :widget_id)
    widget_kind = required_payload_value(payload, :widget_kind)
    intent = event_scoped_value(payload, event_name, :intent, normalize_event_name(event_name))

    signal_attrs = %{
      data: %{
        intent: intent,
        payload: signal_payload(payload, event_name),
        runtime_context: runtime_context,
        widget_id: widget_id,
        widget_kind: widget_kind
      },
      source: signal_source(runtime_context),
      subject: widget_id,
      type: signal_type(widget_kind, intent)
    }

    case Signal.new(signal_attrs) do
      {:ok, signal} ->
        signal

      {:error, reason} ->
        raise ConfigurationError.new("live_ui could not encode event as Jido.Signal", %{
                event_name: normalize_event_name(event_name),
                reason: inspect(reason),
                signal_attrs: inspect(signal_attrs)
              })
    end
  end

  defp normalize_event_name(event_name) when is_binary(event_name), do: event_name
  defp normalize_event_name(event_name) when is_atom(event_name), do: Atom.to_string(event_name)

  defp required_payload_value(payload, key) do
    case optional_payload_value(payload, key) do
      value when is_binary(value) ->
        case String.trim(value) do
          "" ->
            raise ConfigurationError.new("live_ui event payload is missing required metadata", %{
                    field: Atom.to_string(key),
                    payload: inspect(payload)
                  })

          normalized ->
            normalized
        end

      value when is_atom(value) and not is_nil(value) ->
        Atom.to_string(value)

      nil ->
        raise ConfigurationError.new("live_ui event payload is missing required metadata", %{
                field: Atom.to_string(key),
                payload: inspect(payload)
              })

      other ->
        raise ConfigurationError.new("live_ui event payload metadata must be a string or atom", %{
                field: Atom.to_string(key),
                value: inspect(other)
              })
    end
  end

  defp optional_payload_value(payload, key, default \\ nil) do
    Map.get(payload, Atom.to_string(key), Map.get(payload, key, default))
  end

  defp event_scoped_value(payload, event_name, key, default) do
    event_name = normalize_event_name(event_name)
    scoped_key = "event_#{event_name}_#{Atom.to_string(key)}"

    Map.get(
      payload,
      scoped_key,
      Map.get(payload, String.to_atom(scoped_key), optional_payload_value(payload, key, default))
    )
  end

  defp signal_payload(payload, event_name) do
    event_name = normalize_event_name(event_name)

    payload
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      put_signal_payload(acc, normalize_payload_key(key), value, event_name)
    end)
  end

  defp put_signal_payload(acc, key, value, event_name) do
    if key in ["intent", "signal", "widget_id", "widget_kind", "event_#{event_name}_intent"] do
      acc
    else
      do_put_signal_payload(acc, key, value, event_name)
    end
  end

  defp do_put_signal_payload(acc, <<"event_", rest::binary>>, value, event_name) do
    event_prefix = "#{event_name}_"
    json_event_prefix = "#{event_prefix}json_"

    cond do
      String.starts_with?(rest, json_event_prefix) ->
        stripped_key = String.replace_prefix(rest, json_event_prefix, "")
        Map.put(acc, stripped_key, decode_json(value))

      String.starts_with?(rest, event_prefix) ->
        stripped_key = String.replace_prefix(rest, event_prefix, "")
        Map.put(acc, stripped_key, value)

      true ->
        acc
    end
  end

  defp do_put_signal_payload(acc, <<"json_", key::binary>>, value, _event_name),
    do: Map.put(acc, key, decode_json(value))

  defp do_put_signal_payload(acc, key, value, _event_name), do: Map.put(acc, key, value)

  defp normalize_payload_key(key) when is_binary(key), do: key
  defp normalize_payload_key(key) when is_atom(key), do: Atom.to_string(key)
  defp normalize_payload_key(key), do: to_string(key)

  defp decode_json(value) when is_binary(value) do
    case Jason.decode(value) do
      {:ok, decoded} -> decoded
      {:error, _reason} -> value
    end
  end

  defp decode_json(value), do: value

  defp signal_source(runtime_context) do
    runtime_context
    |> optional_payload_value(:signal_source, "/live_ui")
    |> normalize_signal_source()
  end

  defp normalize_signal_source(source) when is_binary(source) do
    case String.trim(source) do
      "" -> "/live_ui"
      normalized -> normalized
    end
  end

  defp normalize_signal_source(source) when is_atom(source),
    do: source |> Atom.to_string() |> normalize_signal_source()

  defp normalize_signal_source(_source), do: "/live_ui"

  defp signal_type(widget_kind, intent) do
    ["live_ui", widget_kind, intent]
    |> Enum.map(&normalize_signal_type_part/1)
    |> Enum.join(".")
  end

  defp normalize_signal_type_part(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9_]+/u, "_")
    |> String.trim("_")
    |> case do
      "" -> raise ConfigurationError.new("live_ui signal type part cannot be empty")
      <<first::utf8, _rest::binary>> = normalized when first in ?a..?z -> normalized
      normalized -> "x_#{normalized}"
    end
  end

  defp normalize_signal_type_part(value) when is_atom(value),
    do: value |> Atom.to_string() |> normalize_signal_type_part()
end
