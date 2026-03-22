defmodule TerminalUi.Backend.RawMode do
  @moduledoc """
  Rich terminal backend adapter summary for raw-mode execution.
  """

  @spec summary() :: map()
  def summary do
    %{
      mode: :raw,
      runtime_module: TermUI.Runtime,
      platform_module: TermUI.Platform,
      event_module: TermUI.Event,
      input_reader_module: TermUI.Terminal.InputReader,
      keyboard_first: true,
      mouse: true,
      paste: true,
      unicode: true,
      color_depth: :true_color,
      callbacks: [:focus, :paste, :resize, :mouse, :shutdown]
    }
  end
end
