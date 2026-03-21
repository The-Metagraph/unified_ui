defmodule WebUi.Transport.Bridge do
  @moduledoc """
  Frontend/server bridge envelopes for `web_ui`.
  """

  alias WebUi.FrontendRuntime.Model

  @spec event_message(Model.t(), map()) :: map()
  def event_message(%Model{} = model, translation) when is_map(translation) do
    WebUi.FrontendRuntime.Message.new(
      :event,
      payload_for(translation),
      %{
        runtime_id: model.runtime_id,
        source_kind: model.source_kind,
        boundary: translation.boundary
      }
    )
  end

  @spec hydration_message(map()) :: map()
  def hydration_message(payload) when is_map(payload) do
    WebUi.FrontendRuntime.Message.new(:hydrate, payload)
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
