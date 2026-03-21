defmodule WebUi.FrontendRuntime.Bridge do
  @moduledoc """
  Browser bridge helpers for outgoing interaction envelopes.
  """

  alias WebUi.FrontendRuntime.Model
  alias WebUi.Transport

  @spec outgoing_interaction(Model.t(), keyword() | map()) :: {:ok, map()} | {:error, term()}
  def outgoing_interaction(%Model{} = model, attrs) do
    attrs =
      attrs
      |> Enum.into(%{})
      |> Map.put_new(:screen, model.title)
      |> Map.put_new(:runtime_id, model.runtime_id)

    with {:ok, translation} <- Transport.from_native_event(attrs) do
      {:ok, WebUi.Transport.Bridge.event_message(model, translation)}
    end
  end
end
