defmodule LiveUi.Runtime do
  @moduledoc """
  Package-facing entrypoint for the server-authoritative LiveView runtime.
  """

  alias LiveUi.Runtime.{BrowserBridge, CanonicalScreen, ScreenComponent, State}
  alias UnifiedIUR.Element

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

  @spec mount_iur(Element.t(), keyword()) :: {:ok, State.t()} | {:error, LiveUi.Runtime.Error.t()}
  def mount_iur(%Element{} = element, opts \\ []) do
    canonical_assigns =
      opts
      |> Keyword.get(:assigns, %{})
      |> Map.put(:iur, element)

    CanonicalScreen
    |> State.mount(Keyword.merge(opts, assigns: canonical_assigns, mode: :canonical))
  end

  @spec handle_event(State.t(), String.t(), map()) ::
          {:ok, State.t()} | {:error, LiveUi.Runtime.Error.t()}
  def handle_event(runtime_state, event, payload) do
    State.handle_event(runtime_state, event, payload)
  end

  @spec modules() :: [module()]
  def modules do
    [State, ScreenComponent, BrowserBridge, CanonicalScreen]
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
      canonical_renderer: :baseline_ready
    }
  end

  @spec component() :: module()
  def component, do: ScreenComponent

  @spec browser_bridge() :: module()
  def browser_bridge, do: BrowserBridge

  @spec namespace() :: module()
  def namespace, do: __MODULE__
end
