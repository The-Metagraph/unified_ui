defmodule WebUi.Transport.Bridge do
  @moduledoc """
  Frontend/server bridge envelopes for `web_ui`.
  """

  alias WebUi.FrontendRuntime.Model

  @spec event_message(Model.t(), map()) :: map()
  def event_message(%Model{} = model, translation) when is_map(translation) do
    %{
      kind: :event,
      runtime_id: model.runtime_id,
      source_kind: model.source_kind,
      boundary: translation.boundary,
      payload: payload_for(translation)
    }
  end

  @spec hydration_message(map()) :: map()
  def hydration_message(payload) when is_map(payload) do
    %{kind: :hydrate, payload: payload}
  end

  defp payload_for(%{boundary: :boundary, signal: signal}) do
    {:ok, message} = WebUi.Transport.to_server_message(signal)
    message
  end

  defp payload_for(translation) do
    {:ok, message} = WebUi.Transport.to_server_message(translation)
    message
  end
end
