defmodule WebUi.ServerRuntime do
  @moduledoc """
  Phoenix server-side runtime entrypoints for web_ui.

  This area provides the server-side components that handle:
  - Phoenix endpoint and router configuration
  - LiveView and LiveComponent mounting
  - Server-authoritative state management
  - Channel definitions for client-server communication

  ## Submodules

  * `State` - Server-authoritative runtime state management
  * `Error` - Deterministic runtime error contract
  * `FrontendSync` - Frontend synchronization and hydration
  * `Channel` - Phoenix channel for browser-server communication
  * `BrowserBridge` - Server-side browser bridge coordination
  * `Diagnostics` - Runtime validation and diagnostics helpers
  """

  alias WebUi.ServerRuntime.{State, Error, FrontendSync, Channel, BrowserBridge, Diagnostics}

  @type state :: State.t()
  @type error :: Error.t()
  @type frontend_sync :: FrontendSync.t()
  @type message_envelope :: Channel.message_envelope()
  @type bridge_state :: BrowserBridge.bridge_state()

  @doc """
  Delegates to `State.mount/2`.
  """
  defdelegate mount(screen, opts \\ []), to: State

  @doc """
  Delegates to `State.handle_event/3`.
  """
  defdelegate handle_event(state, event, payload), to: State

  @doc """
  Delegates to `State.frontend_state/1`.
  """
  defdelegate frontend_state(state), to: State

  @doc """
  Delegates to `BrowserBridge.init/1`.
  """
  defdelegate init_bridge(opts \\ []), to: BrowserBridge, as: :init

  @doc """
  Delegates to `Diagnostics.validate_screen_module/1`.
  """
  defdelegate validate_screen_module(screen), to: Diagnostics
end
