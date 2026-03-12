defmodule WebUi.Ui.Message do
  @moduledoc """
  Typed UI runtime message envelope mirroring Elm Msg semantics.
  """

  @enforce_keys [:type, :payload]
  defstruct [:type, :payload]

  @type type ::
          :ws_joined
          | :ws_join_failed
          | :ws_disconnected
          | :ws_event_received
          | :ws_error_received
          | :ws_pong_received
          | :widget_event
          | :port_event
          | :retry_requested
          | :cancel_requested
          | :replay_snapshot_requested
          | :replay_export_requested
          | :replay_compaction_requested
          | :replay_restore_requested
          | :replay_verification_requested
          | :replay_verification_gate_requested
          | :replay_baseline_capture_requested
          | :replay_baseline_activate_requested
          | :replay_baseline_gate_requested

  @type t :: %__MODULE__{type: type(), payload: map()}

  @spec websocket_joined(map()) :: t()
  def websocket_joined(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :ws_joined, payload: payload}

  @spec websocket_join_failed(map()) :: t()
  def websocket_join_failed(payload) when is_map(payload),
    do: %__MODULE__{type: :ws_join_failed, payload: payload}

  @spec websocket_disconnected(map()) :: t()
  def websocket_disconnected(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :ws_disconnected, payload: payload}

  @spec websocket_recv(map()) :: t()
  def websocket_recv(payload) when is_map(payload),
    do: %__MODULE__{type: :ws_event_received, payload: payload}

  @spec websocket_error(map()) :: t()
  def websocket_error(payload) when is_map(payload),
    do: %__MODULE__{type: :ws_error_received, payload: payload}

  @spec websocket_pong(map()) :: t()
  def websocket_pong(payload) when is_map(payload),
    do: %__MODULE__{type: :ws_pong_received, payload: payload}

  @spec widget_event(map()) :: t()
  def widget_event(payload) when is_map(payload),
    do: %__MODULE__{type: :widget_event, payload: payload}

  @spec port_event(map()) :: t()
  def port_event(payload) when is_map(payload),
    do: %__MODULE__{type: :port_event, payload: payload}

  @spec retry_requested(map()) :: t()
  def retry_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :retry_requested, payload: payload}

  @spec cancel_requested(map()) :: t()
  def cancel_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :cancel_requested, payload: payload}

  @spec replay_snapshot_requested(map()) :: t()
  def replay_snapshot_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :replay_snapshot_requested, payload: payload}

  @spec replay_export_requested(map()) :: t()
  def replay_export_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :replay_export_requested, payload: payload}

  @spec replay_compaction_requested(map()) :: t()
  def replay_compaction_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :replay_compaction_requested, payload: payload}

  @spec replay_restore_requested(map()) :: t()
  def replay_restore_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :replay_restore_requested, payload: payload}

  @spec replay_verification_requested(map()) :: t()
  def replay_verification_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :replay_verification_requested, payload: payload}

  @spec replay_verification_gate_requested(map()) :: t()
  def replay_verification_gate_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :replay_verification_gate_requested, payload: payload}

  @spec replay_baseline_capture_requested(map()) :: t()
  def replay_baseline_capture_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :replay_baseline_capture_requested, payload: payload}

  @spec replay_baseline_activate_requested(map()) :: t()
  def replay_baseline_activate_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :replay_baseline_activate_requested, payload: payload}

  @spec replay_baseline_gate_requested(map()) :: t()
  def replay_baseline_gate_requested(payload \\ %{}) when is_map(payload),
    do: %__MODULE__{type: :replay_baseline_gate_requested, payload: payload}
end
