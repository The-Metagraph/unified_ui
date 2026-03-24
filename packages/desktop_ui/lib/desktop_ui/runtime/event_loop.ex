defmodule DesktopUi.Runtime.EventLoop do
  @moduledoc """
  Shared event-loop scaffold for the `desktop_ui` runtime backbone.
  """

  alias DesktopUi.Runtime.{Dispatch, Frame, Poller, Redraw}

  @spec scaffold(keyword()) :: map()
  def scaffold(opts \\ []) do
    %{
      platform_target: Keyword.get(opts, :platform_target, :linux),
      screen_id: Keyword.get(opts, :screen_id, "screen"),
      poller: Poller.scaffold(),
      redraw: Redraw.scaffold(),
      input_dispatch: Dispatch.scaffold(),
      frame: Frame.scaffold(),
      focus_callbacks: :placeholder_ready,
      shortcut_callbacks: :placeholder_ready,
      window_lifecycle_callbacks: :placeholder_ready
    }
  end

  @spec diagnostics(map()) :: map()
  def diagnostics(loop_state) when is_map(loop_state) do
    %{
      poller: Map.get(loop_state, :poller),
      redraw: Map.get(loop_state, :redraw),
      input_dispatch: Map.get(loop_state, :input_dispatch),
      frame: Map.get(loop_state, :frame),
      focus_callbacks: Map.get(loop_state, :focus_callbacks),
      shortcut_callbacks: Map.get(loop_state, :shortcut_callbacks),
      window_lifecycle_callbacks: Map.get(loop_state, :window_lifecycle_callbacks)
    }
  end
end
