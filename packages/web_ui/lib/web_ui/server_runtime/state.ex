defmodule WebUi.ServerRuntime.State do
  @moduledoc """
  Server-authoritative runtime state for `web_ui`.
  """

  alias UnifiedIUR.Element
  alias WebUi.Widget

  @type boundary_mode :: :native_local | :canonical_boundary
  @type t :: %__MODULE__{
          runtime_id: String.t(),
          source_kind: :native | :canonical,
          title: String.t(),
          screen_id: String.t() | atom(),
          rendered_tree: Widget.t(),
          canonical_element: Element.t() | nil,
          boundary_mode: boundary_mode(),
          diagnostics: [map()],
          event_log: [map()],
          last_boundary_signal: Jido.Signal.t() | nil,
          metadata: map()
        }

  defstruct runtime_id: "web-ui-runtime",
            source_kind: :native,
            title: "",
            screen_id: nil,
            rendered_tree: %Widget{},
            canonical_element: nil,
            boundary_mode: :native_local,
            diagnostics: [],
            event_log: [],
            last_boundary_signal: nil,
            metadata: %{}

  @spec record_event(t(), map()) :: t()
  def record_event(%__MODULE__{} = state, event) when is_map(event) do
    %{state | event_log: state.event_log ++ [event]}
  end

  @spec record_boundary_signal(t(), Jido.Signal.t()) :: t()
  def record_boundary_signal(%__MODULE__{} = state, signal) do
    %{state | last_boundary_signal: signal}
  end
end
