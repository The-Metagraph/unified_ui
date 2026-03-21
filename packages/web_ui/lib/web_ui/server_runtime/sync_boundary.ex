defmodule WebUi.ServerRuntime.SyncBoundary do
  @moduledoc """
  Server-side synchronization boundary for Phoenix-to-Elm envelopes.
  """

  alias WebUi.FrontendRuntime.Message
  alias WebUi.ServerRuntime.{Error, State, ViewState}
  alias WebUi.Transport

  @spec hydration_envelope(State.t()) :: map()
  def hydration_envelope(%State{} = state) do
    Message.new(:hydrate, ViewState.to_frontend_payload(state),
      runtime_id: state.runtime_id,
      source_kind: state.source_kind
    )
  end

  @spec receive_frontend_message(State.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def receive_frontend_message(%State{} = state, payload) when is_map(payload) do
    case Message.from_payload(payload) do
      {:ok, %{kind: :event} = message} ->
        {:ok, Map.put(message, :runtime_id, state.runtime_id)}

      {:ok, %{kind: :ack} = message} ->
        {:ok, Map.put(message, :runtime_id, state.runtime_id)}

      {:ok, %{kind: kind}} ->
        {:error,
         Error.new(:unsupported_frontend_message, "Unsupported frontend message kind", %{
           kind: kind
         })}

      {:error, reason} ->
        {:error,
         Error.new(:unsupported_frontend_message, "Invalid frontend message", %{reason: reason})}
    end
  end

  def receive_frontend_message(_state, _payload) do
    {:error,
     Error.new(:unsupported_frontend_message, "Expected frontend message payload to be a map")}
  end

  @spec translation_for_message(State.t(), Message.t()) :: {:ok, map()} | {:error, Error.t()}
  def translation_for_message(%State{} = state, %{kind: :event, payload: payload})
      when is_map(payload) do
    payload =
      payload
      |> normalize_map()
      |> Map.put_new(:runtime_id, state.runtime_id)
      |> Map.put_new(:screen, state.screen_id)
      |> Map.put_new(:source_kind, state.source_kind)
      |> Map.put_new(:boundary_mode, state.boundary_mode)

    with :ok <- validate_frontend_payload(payload) do
      case normalize_boundary(fetch(payload, :boundary)) do
        :boundary ->
          boundary_signal = fetch(payload, :cloud_event) || fetch(payload, :signal)

          if is_nil(boundary_signal) do
            {:error,
             Error.new(
               :missing_boundary_signal,
               "Boundary frontend events must include a canonical boundary envelope"
             )}
          else
            case Transport.from_boundary_signal(boundary_signal) do
              {:ok, translation} ->
                {:ok,
                 translation
                 |> Map.put_new(:runtime_id, state.runtime_id)
                 |> Map.put_new(:screen, state.screen_id)}

              {:error, reason} ->
                {:error,
                 Error.new(:invalid_event_route, "Unable to translate boundary frontend event", %{
                   reason: reason
                 })}
            end
          end

        _local ->
          case Transport.from_native_event(payload |> Map.put(:boundary, :local)) do
            {:ok, translation} ->
              {:ok, translation}

            {:error, reason} ->
              {:error,
               Error.new(:invalid_event_route, "Unable to translate frontend event", %{
                 reason: reason
               })}
          end
      end
    end
  end

  def translation_for_message(_state, %{kind: kind}) do
    {:error,
     Error.new(:unsupported_frontend_message, "Expected an event message at the sync boundary", %{
       kind: kind
     })}
  end

  @spec acknowledgement_envelope(State.t(), map()) :: map()
  def acknowledgement_envelope(%State{} = state, translation) when is_map(translation) do
    Message.new(
      :ack,
      %{
        runtime_id: state.runtime_id,
        screen_id: state.screen_id,
        family: translation.family,
        intent: translation.intent,
        boundary: translation.boundary,
        runtime_event: translation.runtime_event,
        event_count: length(state.event_log),
        server_authority: true,
        diagnostics: state.diagnostics
      },
      %{
        source_kind: state.source_kind,
        boundary_mode: state.boundary_mode
      }
    )
  end

  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})
  defp normalize_map(_value), do: %{}

  defp normalize_boundary(:boundary), do: :boundary
  defp normalize_boundary("boundary"), do: :boundary
  defp normalize_boundary(_value), do: :local

  defp validate_frontend_payload(payload) do
    leaked_keys =
      payload
      |> leaked_keys()
      |> Kernel.++(payload |> fetch(:payload, %{}) |> normalize_map() |> leaked_keys())
      |> Enum.uniq()

    if leaked_keys == [] do
      :ok
    else
      {:error,
       Error.new(
         :frontend_payload_leakage,
         "Frontend event payload leaked renderer-local keys",
         %{keys: leaked_keys}
       )}
    end
  end

  defp leaked_keys(map) when is_map(map) do
    map
    |> Map.keys()
    |> Enum.filter(&renderer_local_key?/1)
  end

  defp leaked_keys(_value), do: []

  defp renderer_local_key?(key) when is_atom(key), do: renderer_local_key?(Atom.to_string(key))

  defp renderer_local_key?(key) when is_binary(key) do
    Enum.any?(["phx_", "elm_", "browser_", "dom_"], &String.starts_with?(key, &1))
  end

  defp renderer_local_key?(_key), do: false

  defp fetch(map, key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp fetch(map, key, default) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key)) || default
  end
end
