defmodule WebUi.FrontendRuntime.Bridge do
  @moduledoc """
  Browser bridge helpers for outgoing interaction envelopes.
  """

  alias WebUi.FrontendRuntime.{Message, Model}
  alias WebUi.Transport

  @spec outgoing_interaction(Model.t(), keyword() | map()) :: {:ok, map()} | {:error, term()}
  def outgoing_interaction(%Model{} = model, attrs) do
    attrs =
      attrs
      |> Enum.into(%{})
      |> Map.put_new(:screen, model.title)
      |> Map.put_new(:runtime_id, model.runtime_id)
      |> Map.put_new(:source_kind, model.source_kind)
      |> Map.put_new(:boundary_mode, model.boundary_mode)

    with {:ok, translation} <- Transport.from_native_event(attrs) do
      {:ok, WebUi.Transport.Bridge.event_message(model, translation)}
    end
  end

  @spec incoming_message(map()) :: {:ok, Message.t()} | {:error, term()}
  def incoming_message(payload) do
    Message.from_payload(payload)
  end
end
