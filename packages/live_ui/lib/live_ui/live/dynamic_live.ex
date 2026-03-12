defmodule LiveUi.Live.DynamicLive do
  @moduledoc """
  Generic dynamic LiveView entrypoint backed by the shared engine.
  """

  use Phoenix.LiveView

  alias LiveUi.Live.Engine

  @impl true
  def mount(params, session, socket) do
    Engine.mount_dynamic(params, session, socket)
  end

  @impl true
  def handle_event(event_name, payload, socket) do
    Engine.handle_event(event_name, payload, socket, __MODULE__)
  end

  @impl true
  def render(assigns) do
    Engine.render(assigns)
  end
end
