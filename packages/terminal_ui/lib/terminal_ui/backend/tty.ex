defmodule TerminalUi.Backend.Tty do
  @moduledoc """
  Limited terminal backend adapter summary for TTY-compatible execution.
  """

  @spec summary() :: map()
  def summary do
    %{
      mode: :tty,
      runtime_module: TermUI.Runtime,
      platform_module: TermUI.Platform,
      event_module: TermUI.Event,
      input_reader_module: TermUI.Terminal.InputReader,
      keyboard_first: true,
      mouse: false,
      paste: false,
      unicode: false,
      color_depth: :ansi16,
      callbacks: [:focus, :resize, :shutdown],
      keyboard_alternatives: [:inline_menu_selection, :ctrl_resize, :arrow_navigation]
    }
  end
end
