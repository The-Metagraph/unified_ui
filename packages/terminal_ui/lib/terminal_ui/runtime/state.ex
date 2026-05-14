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
    :root,
    :screen,
    :realization
  ]
  defstruct [
    :runtime_id,
    :screen_id,
    :title,
    :source_kind,
    :backend_mode,
    :capabilities,
    :root,
    :screen,
    :realization,
    :focus,
    :backend_adapter,
    :event_loop,
    :lifecycle,
    :validation_state,
    navigation: %{
      modals: [],
      current_modal: nil,
      last_transition: nil,
      diagnostics: []
    },
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
          screen: TerminalUi.Runtime.Screen.t(),
          realization: map(),
          focus: map() | nil,
          backend_adapter: map(),
          event_loop: map(),
          lifecycle: map(),
          validation_state: atom(),
          navigation: map(),
          event_log: [map()]
        }
end
