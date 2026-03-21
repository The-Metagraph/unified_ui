defmodule WebUi.Transport.Signals do
  @moduledoc """
  Translation between native `web_ui` events and canonical `Jido.Signal`
  boundary envelopes.
  """

  alias Jido.Signal

  @families [:click, :change, :submit, :open, :close, :navigation, :selection, :command]
  @local_default_families [:click, :change, :open, :close]
  @boundary_crossing_families [:submit, :navigation, :selection, :command]

  @spec families() :: [atom()]
  def families, do: @families

  @spec local_default_families() :: [atom()]
  def local_default_families, do: @local_default_families

  @spec boundary_crossing_families() :: [atom()]
  def boundary_crossing_families, do: @boundary_crossing_families

  @spec from_native_event(keyword() | map()) :: {:ok, map()} | {:error, term()}
  def from_native_event(attrs) do
    attrs = normalize_map(attrs)
    family = attrs |> fetch(:family, :click) |> normalize_family()

    with :ok <- validate_family(family) do
      intent = fetch(attrs, :intent, family)
      boundary = resolve_boundary(attrs, family)
      payload = fetch(attrs, :payload, %{}) |> normalize_map()
      target = fetch(attrs, :target, %{}) |> normalize_map()
      runtime_event = fetch(attrs, :runtime_event, default_runtime_event(family, intent))

      translation = %{
        boundary: boundary,
        family: family,
        intent: intent,
        runtime_event: runtime_event,
        payload: payload,
        target: target,
        source_kind: normalize_source_kind(fetch(attrs, :source_kind, :native)),
        boundary_mode: normalize_boundary_mode(fetch(attrs, :boundary_mode)),
        widget_id: fetch(attrs, :widget_id),
        runtime_id: fetch(attrs, :runtime_id),
        screen: fetch(attrs, :screen, "unknown")
      }

      case boundary do
        :boundary ->
          with {:ok, signal} <- build_signal(translation) do
            cloud_event = cloud_event_envelope(signal)

            {:ok,
             translation
             |> Map.put(:signal, signal)
             |> Map.put(:cloud_event, cloud_event)
             |> Map.put(:server_action, runtime_action(translation, :canonical_boundary_event))
             |> Map.put(:frontend_update, frontend_update(translation, :server_sync))}
          end

        :local ->
          {:ok,
           translation
           |> Map.put(:native_event, %{
             widget_id: fetch(attrs, :widget_id),
             target: target
           })
           |> Map.put(:server_action, runtime_action(translation, :local_runtime_event))
           |> Map.put(:frontend_update, frontend_update(translation, :bounded_local_feedback))}
      end
    end
  end

  @spec from_boundary_signal(Signal.t() | map()) :: {:ok, map()} | {:error, term()}
  def from_boundary_signal(%Signal{} = signal) do
    family = signal |> fetch_extension(:web_ui_family, :click) |> normalize_family()

    with :ok <- validate_family(family) do
      intent = fetch_extension(signal, :web_ui_intent, family)

      runtime_event =
        fetch_extension(signal, :web_ui_runtime_event, default_runtime_event(family, intent))

      translation = %{
        boundary: :boundary,
        family: family,
        intent: intent,
        runtime_event: runtime_event,
        payload: normalize_map(signal.data || %{}),
        target: normalize_map(fetch_extension(signal, :web_ui_target, %{})),
        source_kind:
          normalize_source_kind(fetch_extension(signal, :web_ui_source_kind, :canonical)),
        boundary_mode: :canonical_boundary,
        widget_id: signal.subject,
        runtime_id: fetch_extension(signal, :web_ui_runtime_id),
        screen: fetch_extension(signal, :web_ui_screen, "unknown"),
        signal: signal,
        cloud_event: cloud_event_envelope(signal)
      }

      {:ok,
       translation
       |> Map.put(:server_action, runtime_action(translation, :canonical_boundary_event))
       |> Map.put(:frontend_update, frontend_update(translation, :server_sync))}
    end
  end

  def from_boundary_signal(%{signal: %Signal{} = signal}), do: from_boundary_signal(signal)
  def from_boundary_signal(_signal), do: {:error, :invalid_boundary_signal}

  @spec cloud_event_envelope(Signal.t()) :: map()
  def cloud_event_envelope(%Signal{} = signal) do
    %{
      specversion: signal.specversion,
      id: signal.id,
      type: signal.type,
      source: signal.source,
      subject: signal.subject,
      time: signal.time,
      datacontenttype: signal.datacontenttype,
      dataschema: signal.dataschema,
      data: signal.data,
      extensions: signal.extensions
    }
  end

  @spec to_server_message(Signal.t() | map()) :: {:ok, map()} | {:error, term()}
  def to_server_message(%Signal{} = signal) do
    with {:ok, translation} <- from_boundary_signal(signal) do
      {:ok,
       translation
       |> Map.take([
         :boundary,
         :family,
         :intent,
         :runtime_event,
         :target,
         :payload,
         :server_action,
         :frontend_update,
         :cloud_event
       ])
       |> Map.put(:type, signal.type)}
    end
  end

  def to_server_message(%{boundary: :boundary, signal: %Signal{} = signal}) do
    to_server_message(signal)
  end

  def to_server_message(%{boundary: :local} = local_event) do
    {:ok,
     Map.take(local_event, [
       :boundary,
       :family,
       :intent,
       :runtime_event,
       :payload,
       :native_event,
       :server_action,
       :frontend_update
     ])}
  end

  def to_server_message(_event), do: {:error, :invalid_transport_event}

  defp build_signal(translation) do
    Signal.new(
      "web_ui.#{translation.family}.#{translation.intent}",
      translation.payload,
      source: signal_source(translation),
      subject: signal_subject(translation),
      extensions: %{
        web_ui_family: translation.family,
        web_ui_intent: translation.intent,
        web_ui_runtime_event: translation.runtime_event,
        web_ui_target: translation.target,
        web_ui_source_kind: translation.source_kind,
        web_ui_runtime_id: translation.runtime_id,
        web_ui_screen: translation.screen
      }
    )
  end

  defp runtime_action(translation, kind) do
    %{
      kind: kind,
      family: translation.family,
      intent: translation.intent,
      runtime_event: translation.runtime_event,
      widget_behavior: widget_behavior(translation.family),
      server_authority: :preserved
    }
  end

  defp frontend_update(translation, mode) do
    %{
      mode: mode,
      family: translation.family,
      intent: translation.intent,
      optimistic?: translation.family in @local_default_families
    }
  end

  defp widget_behavior(family) when family in [:open, :close], do: :layer_visibility
  defp widget_behavior(family) when family in [:navigation, :selection], do: :active_target
  defp widget_behavior(:command), do: :command_dispatch
  defp widget_behavior(:submit), do: :form_commit
  defp widget_behavior(_family), do: :widget_interaction

  defp resolve_boundary(attrs, family) do
    case normalize_boundary(fetch(attrs, :boundary, :__missing__)) do
      boundary when boundary in [:local, :boundary] ->
        boundary

      _missing ->
        if canonical_source?(attrs) or family in @boundary_crossing_families do
          :boundary
        else
          :local
        end
    end
  end

  defp canonical_source?(attrs) do
    fetch(attrs, :source_kind) in [:canonical, "canonical"] or
      fetch(attrs, :boundary_mode) in [:canonical_boundary, "canonical_boundary"]
  end

  defp validate_family(family) when family in @families, do: :ok
  defp validate_family(_family), do: {:error, :unsupported_transport_family}

  defp default_runtime_event(family, intent), do: "#{family}:#{intent}"

  defp fetch(map, key, default \\ nil) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key)) || default
  end

  defp fetch_extension(signal, key, default \\ nil) do
    Map.get(signal.extensions, key) || Map.get(signal.extensions, Atom.to_string(key)) || default
  end

  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})
  defp normalize_map(nil), do: %{}

  defp normalize_family(value) when is_atom(value), do: value

  defp normalize_family(value) when is_binary(value) do
    Enum.find(@families, fn family -> Atom.to_string(family) == value end) || value
  end

  defp normalize_boundary(value) when value in [:local, :boundary], do: value
  defp normalize_boundary("local"), do: :local
  defp normalize_boundary("boundary"), do: :boundary
  defp normalize_boundary(value), do: value

  defp normalize_source_kind(value) when value in [:native, :canonical], do: value
  defp normalize_source_kind("native"), do: :native
  defp normalize_source_kind("canonical"), do: :canonical
  defp normalize_source_kind(_value), do: :native

  defp normalize_boundary_mode(value) when value in [:native_local, :canonical_boundary],
    do: value

  defp normalize_boundary_mode("native_local"), do: :native_local
  defp normalize_boundary_mode("canonical_boundary"), do: :canonical_boundary
  defp normalize_boundary_mode(_value), do: :native_local

  defp normalize_segment(value) when is_atom(value), do: Atom.to_string(value)
  defp normalize_segment(value) when is_binary(value), do: value

  defp signal_source(translation) do
    "/web_ui/#{translation.source_kind}/#{normalize_segment(translation.screen)}"
  end

  defp signal_subject(%{widget_id: nil, runtime_id: runtime_id}) when not is_nil(runtime_id),
    do: to_string(runtime_id)

  defp signal_subject(%{widget_id: widget_id}) when not is_nil(widget_id),
    do: to_string(widget_id)

  defp signal_subject(_translation), do: "web-ui"
end
