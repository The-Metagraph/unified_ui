defmodule WebUi.Ui.Model do
  @moduledoc """
  Deterministic UI runtime model baseline used to mirror Elm Model semantics.
  """

  alias WebUi.Transport.Naming
  alias WebUi.Persistence.ReplayBaselineRegistry

  @type connection_state :: :disconnected | :connecting | :connected | :error

  @enforce_keys [:connection_state, :runtime_context, :view_state, :transport]
  defstruct [
    :connection_state,
    :runtime_context,
    :view_state,
    :transport,
    :slice_state,
    :recovery_state,
    :last_error,
    outbound_queue: [],
    inbound_history: [],
    telemetry_events: []
  ]

  @type t :: %__MODULE__{
          connection_state: connection_state(),
          runtime_context: map(),
          view_state: map(),
          transport: map(),
          slice_state: map(),
          recovery_state: map(),
          last_error: map() | nil,
          outbound_queue: [map()],
          inbound_history: [map()],
          telemetry_events: [map()]
        }

  @default_runtime_context %{
    correlation_id: "bootstrap-correlation",
    request_id: "bootstrap-request",
    session_id: nil,
    client_id: nil,
    user_id: nil,
    trace_id: nil
  }

  @default_view_state %{
    screen: :booting,
    ui_error: nil,
    notices: [],
    reconciliation_hints: %{
      primary_notice: nil,
      severity: nil,
      next_actions: [],
      focus_field: nil
    }
  }

  @default_transport %{
    topic: Naming.default_topic(),
    joined?: false,
    last_pong_at: nil
  }

  @default_slice_state %{
    workflow: nil,
    status: :idle,
    last_outcome: nil,
    attempts: 0,
    pending_action: nil,
    dispatch_sequence: 0,
    active_turn_id: nil,
    last_completed_turn_id: nil
  }

  @default_recovery_state %{
    reconnect_attempts: 0,
    session_resume_topic: nil,
    session_resume_cursor: nil,
    last_resumed_sequence: nil,
    replay_log: %{cursor: 0, entries: [], last_checkpoint_id: nil},
    replay_cursor: 0,
    last_replay_checkpoint_id: nil,
    replay_retention_limit: nil,
    last_replay_snapshot: nil,
    last_replay_export: nil,
    last_replay_restore: nil,
    replay_baseline_registry: ReplayBaselineRegistry.new(),
    last_replay_baseline: nil,
    last_replay_baseline_gate: nil,
    last_replay_verification: nil,
    last_replay_verification_gate: nil,
    retry_pending?: false,
    retryable_error: nil,
    last_command: nil,
    retry_attempts: 0,
    retry_backoff_ms: nil
  }

  @spec new(map()) :: t()
  def new(opts \\ %{}) when is_map(opts) do
    runtime_context = Map.merge(@default_runtime_context, Map.get(opts, :runtime_context, %{}))
    view_state = Map.merge(@default_view_state, Map.get(opts, :view_state, %{}))
    transport = Map.merge(@default_transport, Map.get(opts, :transport, %{}))
    slice_state = Map.merge(@default_slice_state, Map.get(opts, :slice_state, %{}))
    recovery_state = Map.merge(@default_recovery_state, Map.get(opts, :recovery_state, %{}))

    %__MODULE__{
      connection_state: Map.get(opts, :connection_state, :disconnected),
      runtime_context: runtime_context,
      view_state: view_state,
      transport: transport,
      slice_state: slice_state,
      recovery_state: recovery_state,
      last_error: Map.get(opts, :last_error),
      outbound_queue: Map.get(opts, :outbound_queue, []),
      inbound_history: Map.get(opts, :inbound_history, []),
      telemetry_events: Map.get(opts, :telemetry_events, [])
    }
  end
end
