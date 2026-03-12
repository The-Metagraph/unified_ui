defmodule LiveUi.Session do
  @moduledoc """
  Normalizes host session and route context for the shared runtime engine.
  """

  alias LiveUi.ConfigurationError
  alias Phoenix.LiveView.Socket

  @spec normalize(map(), map(), Socket.t(), map()) :: map()
  def normalize(params, session, socket, extra_context \\ %{})

  def normalize(params, session, %Socket{} = socket, extra_context)
      when is_map(params) and is_map(session) and is_map(extra_context) do
    %{
      connected?: Phoenix.LiveView.connected?(socket),
      live_action: Map.get(socket.assigns, :live_action),
      params: params,
      session: session,
      socket_id: socket.id,
      view: socket.view
    }
    |> Map.merge(extra_context)
  end

  def normalize(_params, _session, _socket, _extra_context) do
    raise ConfigurationError.new(
            "live_ui session normalization expects map params, map session, and map context"
          )
  end
end
