defmodule LiveUi.Runtime do
  @moduledoc """
  Package-facing entrypoint for the server-authoritative LiveView runtime.
  """

  alias LiveUi.Runtime.{BrowserBridge, ScreenComponent, State}

  @type capability ::
          :native_mount
          | :native_render
          | :event_handling
          | :browser_bridge_placeholders

  @spec capabilities() :: [capability()]
  def capabilities do
    [:native_mount, :native_render, :event_handling, :browser_bridge_placeholders]
  end

  @spec mount(module(), keyword()) :: {:ok, State.t()} | {:error, LiveUi.Runtime.Error.t()}
  def mount(screen, opts \\ []) do
    State.mount(screen, opts)
  end

  @spec handle_event(State.t(), String.t(), map()) ::
          {:ok, State.t()} | {:error, LiveUi.Runtime.Error.t()}
  def handle_event(runtime_state, event, payload) do
    State.handle_event(runtime_state, event, payload)
  end

  @spec component() :: module()
  def component, do: ScreenComponent

  @spec browser_bridge() :: module()
  def browser_bridge, do: BrowserBridge

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
