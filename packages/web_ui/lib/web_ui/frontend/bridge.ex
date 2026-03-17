defmodule WebUi.Frontend.Bridge do
  @moduledoc """
  Browser-bridge helpers for the scaffolded frontend runtime.
  """

  alias WebUi.Frontend.{Bootstrap, Error, Model}
  alias WebUi.Server.Sync

  def outbound(model, event, payload, opts \\ [])

  @spec outbound(Model.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def outbound(%Model{} = model, event, payload, opts)
      when is_binary(event) and is_map(payload) do
    {:ok,
     %{
       event: event,
       payload: payload,
       source: %{
         screen_id: model.screen_id,
         revision: model.server_revision,
         element_id: Keyword.get(opts, :element_id),
         widget: Keyword.get(opts, :widget)
       }
     }}
  end

  def outbound(_model, _event, payload, _opts),
    do: {:error, Error.invalid_outbound_message(payload)}

  @spec ingest_sync(map()) :: {:ok, Model.t()} | {:error, term()}
  def ingest_sync(envelope) when is_map(envelope) do
    with {:ok, %{payload: payload}} <- Sync.inbound(envelope),
         {:ok, model} <- Bootstrap.hydrate(payload) do
      {:ok, model}
    end
  end
end
