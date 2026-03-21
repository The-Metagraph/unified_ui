defmodule WebUi.Transport.Signals do
  @moduledoc """
  Translation between native `web_ui` events and canonical `Jido.Signal`
  boundary envelopes.
  """

  alias Jido.Signal

  @spec from_native_event(keyword() | map()) :: {:ok, map()} | {:error, term()}
  def from_native_event(attrs) do
    attrs = normalize_map(attrs)
    family = fetch(attrs, :family, :click)
    boundary = fetch(attrs, :boundary, :local)
    payload = fetch(attrs, :payload, %{})
    runtime_event = fetch(attrs, :runtime_event, "#{family}:#{fetch(attrs, :intent, family)}")

    case boundary do
      :boundary ->
        with {:ok, signal} <-
               Signal.new(
                 "web_ui.#{family}.#{fetch(attrs, :intent, family)}",
                 payload,
                 source:
                   "/web_ui/frontend/#{normalize_segment(fetch(attrs, :screen, "unknown"))}",
                 subject:
                   to_string(fetch(attrs, :widget_id, fetch(attrs, :runtime_id, "web-ui"))),
                 extensions: %{
                   web_ui_family: family,
                   web_ui_intent: fetch(attrs, :intent),
                   web_ui_runtime_event: runtime_event,
                   web_ui_target: fetch(attrs, :target, %{})
                 }
               ) do
          {:ok,
           %{
             boundary: :boundary,
             family: family,
             runtime_event: runtime_event,
             payload: payload,
             signal: signal
           }}
        end

      _local ->
        {:ok,
         %{
           boundary: :local,
           family: family,
           runtime_event: runtime_event,
           payload: payload,
           native_event: %{
             widget_id: fetch(attrs, :widget_id),
             target: fetch(attrs, :target, %{})
           }
         }}
    end
  end

  @spec to_server_message(Signal.t() | map()) :: {:ok, map()} | {:error, term()}
  def to_server_message(%Signal{} = signal) do
    {:ok,
     %{
       type: signal.type,
       family: fetch_extension(signal, :web_ui_family),
       intent: fetch_extension(signal, :web_ui_intent),
       runtime_event: fetch_extension(signal, :web_ui_runtime_event),
       target: fetch_extension(signal, :web_ui_target, %{}),
       payload: Map.new(signal.data || %{})
     }}
  end

  def to_server_message(%{boundary: :local} = local_event) do
    {:ok, Map.take(local_event, [:boundary, :family, :runtime_event, :payload, :native_event])}
  end

  def to_server_message(_event), do: {:error, :invalid_transport_event}

  defp fetch(map, key, default \\ nil) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key)) || default
  end

  defp fetch_extension(signal, key, default \\ nil) do
    Map.get(signal.extensions, key) || Map.get(signal.extensions, Atom.to_string(key)) || default
  end

  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp normalize_segment(value) when is_atom(value), do: Atom.to_string(value)
  defp normalize_segment(value) when is_binary(value), do: value
end
