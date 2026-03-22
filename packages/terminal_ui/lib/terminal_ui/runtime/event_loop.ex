defmodule TerminalUi.Runtime.EventLoop do
  @moduledoc """
  Shared event-loop scaffold for the `terminal_ui` runtime backbone.
  """

  @spec scaffold(keyword()) :: map()
  def scaffold(opts \\ []) do
    %{
      backend_mode: Keyword.get(opts, :backend_mode, :raw),
      screen_id: Keyword.get(opts, :screen_id, "screen"),
      redraw_requests: 0,
      local_events: 0,
      boundary_events: 0,
      input_dispatch: :normalized_transport_ready,
      focus_callbacks: :placeholder_ready,
      paste_callbacks: :placeholder_ready,
      resize_callbacks: :placeholder_ready,
      routing_state: :shared_runtime_ready
    }
  end

  @spec redraw_request(map(), atom()) :: map()
  def redraw_request(loop_state, reason) when is_map(loop_state) and is_atom(reason) do
    Map.update!(loop_state, :redraw_requests, &(&1 + 1))
    |> Map.put(:last_redraw_reason, reason)
  end

  @spec record_route(map(), map()) :: map()
  def record_route(loop_state, route_result) when is_map(loop_state) and is_map(route_result) do
    count_key =
      if route_result.route == :canonical_boundary, do: :boundary_events, else: :local_events

    loop_state
    |> Map.update!(count_key, &(&1 + 1))
    |> Map.put(:last_route, route_result.route)
    |> Map.put(:last_runtime_event, route_result.runtime_event)
    |> Map.put(:last_family, route_result.family)
    |> Map.put(:last_input_family, route_result.input_family)
  end

  @spec diagnostics(map()) :: map()
  def diagnostics(loop_state) when is_map(loop_state) do
    %{
      redraw_requests: Map.get(loop_state, :redraw_requests, 0),
      local_events: Map.get(loop_state, :local_events, 0),
      boundary_events: Map.get(loop_state, :boundary_events, 0),
      input_dispatch: Map.get(loop_state, :input_dispatch),
      focus_callbacks: Map.get(loop_state, :focus_callbacks),
      paste_callbacks: Map.get(loop_state, :paste_callbacks),
      resize_callbacks: Map.get(loop_state, :resize_callbacks),
      routing_state: Map.get(loop_state, :routing_state),
      last_route: Map.get(loop_state, :last_route),
      last_runtime_event: Map.get(loop_state, :last_runtime_event),
      last_family: Map.get(loop_state, :last_family),
      last_input_family: Map.get(loop_state, :last_input_family)
    }
  end
end
