defmodule WebUi.ServerRuntime.SyncBoundary do
  @moduledoc """
  Server-side synchronization boundary for Phoenix-to-Elm envelopes.
  """

  alias WebUi.FrontendRuntime.Message
  alias WebUi.ServerRuntime.{Error, State, ViewState}

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
end
