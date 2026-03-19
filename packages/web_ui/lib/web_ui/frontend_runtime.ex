defmodule WebUi.FrontendRuntime do
  @moduledoc """
  Elm client-side runtime modules for web_ui.

  This area provides the Elm-based frontend components that handle:
  - Client-side widget rendering
  - Local state management
  - Event handling and user interaction
  - Server communication via the transport layer

  The Elm runtime is compiled to JavaScript and served as static assets
  by the Phoenix application.

  ## Submodules

  * `Boot` - Frontend boot process and hydration
  * `Bridge` - Frontend bridge boundary for server communication
  * `Diagnostics` - Frontend runtime validation and diagnostics
  """

  alias WebUi.FrontendRuntime.{Boot, Bridge, Diagnostics}

  @type boot_config :: Boot.boot_config()
  @type hydration_state :: Boot.hydration_state()
  @type outbound_message :: Bridge.outbound_message()
  @type inbound_message :: Bridge.inbound_message()

  @doc """
  Delegates to `Boot.default_config/0`.
  """
  defdelegate default_boot_config, to: Boot, as: :default_config

  @doc """
  Delegates to `Boot.prepare_hydration/1`.
  """
  defdelegate prepare_hydration(state), to: Boot

  @doc """
  Delegates to `Bridge.outbound/2`.
  """
  defdelegate outbound(type, payload), to: Bridge

  @doc """
  Delegates to `Diagnostics.validate_hydration_state/1`.
  """
  defdelegate validate_hydration_state(state), to: Diagnostics

  @doc """
  Delegates to `Diagnostics.validate_outbound_message/1`.
  """
  defdelegate validate_outbound_message(message), to: Diagnostics
end
