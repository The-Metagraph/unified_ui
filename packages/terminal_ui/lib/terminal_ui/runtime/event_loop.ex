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
      input_dispatch: :scaffold_ready,
      focus_callbacks: :placeholder_ready,
      paste_callbacks: :placeholder_ready,
      resize_callbacks: :placeholder_ready
    }
  end

  @spec redraw_request(map(), atom()) :: map()
  def redraw_request(loop_state, reason) when is_map(loop_state) and is_atom(reason) do
    Map.update!(loop_state, :redraw_requests, &(&1 + 1))
    |> Map.put(:last_redraw_reason, reason)
  end

  @spec diagnostics(map()) :: map()
  def diagnostics(loop_state) when is_map(loop_state) do
    %{
      redraw_requests: Map.get(loop_state, :redraw_requests, 0),
      input_dispatch: Map.get(loop_state, :input_dispatch),
      focus_callbacks: Map.get(loop_state, :focus_callbacks),
      paste_callbacks: Map.get(loop_state, :paste_callbacks),
      resize_callbacks: Map.get(loop_state, :resize_callbacks)
    }
  end
end
