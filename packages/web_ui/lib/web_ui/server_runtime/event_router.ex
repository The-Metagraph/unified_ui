defmodule WebUi.ServerRuntime.EventRouter do
  @moduledoc """
  Deterministic routing for native-local and canonical-boundary translations.
  """

  alias WebUi.ServerRuntime.{Error, State}

  @type route :: :local_runtime | :canonical_boundary

  @spec route(State.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def route(%State{} = state, translation) when is_map(translation) do
    with :ok <- validate_translation(translation) do
      {:ok,
       %{
         route: route_for(translation),
         runtime_id: state.runtime_id,
         screen_id: state.screen_id,
         family: translation.family,
         runtime_event: translation.runtime_event,
         boundary: translation.boundary,
         translation: translation
       }}
    end
  end

  def route(_state, _translation) do
    {:error, Error.new(:invalid_event_route, "Expected runtime translation to be a map")}
  end

  defp validate_translation(%{boundary: :boundary, signal: nil}) do
    {:error,
     Error.new(
       :missing_boundary_signal,
       "Boundary translations must provide a Jido.Signal payload"
     )}
  end

  defp validate_translation(%{runtime_event: runtime_event})
       when not is_binary(runtime_event) or runtime_event == "" do
    {:error, Error.new(:invalid_event_route, "Runtime translations must include a runtime_event")}
  end

  defp validate_translation(%{family: family, boundary: boundary})
       when family in [:click, :change, :submit, :navigation] and boundary in [:local, :boundary] do
    :ok
  end

  defp validate_translation(_translation) do
    {:error, Error.new(:invalid_event_route, "Unsupported translation family or boundary")}
  end

  defp route_for(%{boundary: :boundary}), do: :canonical_boundary
  defp route_for(_translation), do: :local_runtime
end
