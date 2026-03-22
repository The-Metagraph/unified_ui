defmodule TerminalUi.Runtime.State do
  @moduledoc """
  Authoritative runtime state for the `terminal_ui` Phase 1 backbone.
  """

  @enforce_keys [
    :runtime_id,
    :screen_id,
    :source_kind,
    :backend_mode,
    :capabilities,
    :root
  ]
  defstruct [
    :runtime_id,
    :screen_id,
    :title,
    :source_kind,
    :backend_mode,
    :capabilities,
    :root,
    :backend_adapter,
    :event_loop,
    :lifecycle,
    :validation_state,
    event_log: []
  ]

  @type source_kind :: :native | :canonical

  @type t :: %__MODULE__{
          runtime_id: String.t(),
          screen_id: String.t(),
          title: String.t() | nil,
          source_kind: source_kind(),
          backend_mode: atom(),
          capabilities: map(),
          root: map(),
          backend_adapter: map(),
          event_loop: map(),
          lifecycle: map(),
          validation_state: atom(),
          event_log: [map()]
        }
end
