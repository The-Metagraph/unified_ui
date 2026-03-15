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

  @spec modules() :: [module()]
  def modules do
    [State, ScreenComponent, BrowserBridge]
  end

  @spec assumptions() :: map()
  def assumptions do
    %{
      server_authoritative?: true,
      browser_bridge_authoritative?: false,
      shared_runtime_for_native_and_iur?: true
    }
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      mount: :ready,
      event_routing: :ready,
      live_component_host: :ready,
      canonical_renderer: :pending
    }
  end

  @spec component() :: module()
  def component, do: ScreenComponent

  @spec browser_bridge() :: module()
  def browser_bridge, do: BrowserBridge

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
