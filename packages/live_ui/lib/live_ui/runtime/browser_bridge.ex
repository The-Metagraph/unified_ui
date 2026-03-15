defmodule LiveUi.Runtime.BrowserBridge do
  @moduledoc """
  Bounded browser-bridge placeholders for hooks and channel integration.
  """

  @type hook :: atom()
  @supported_hooks [
    :resize_observer,
    :viewport_measurement,
    :scroll_tracking,
    :canvas_pointer,
    :split_pane_drag
  ]

  @spec supported_hooks() :: [hook()]
  def supported_hooks do
    @supported_hooks
  end

  @spec normalize_hooks([hook()]) :: [hook()]
  def normalize_hooks(hooks) when is_list(hooks) do
    hooks
    |> Enum.uniq()
    |> Enum.filter(&supported?/1)
  end

  @spec authoritative?() :: boolean()
  def authoritative?, do: false

  @spec display_hooks() :: [hook()]
  def display_hooks do
    LiveUi.Display.browser_bridge_hooks()
  end

  @spec supported?(hook()) :: boolean()
  def supported?(hook) when is_atom(hook) do
    hook in @supported_hooks
  end
end
