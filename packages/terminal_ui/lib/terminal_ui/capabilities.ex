defmodule TerminalUi.Capabilities do
  @moduledoc """
  Capability summary boundary for `terminal_ui`.
  """

  @spec categories() :: [atom()]
  def categories do
    [:backend, :color, :unicode, :mouse, :paste, :resize, :terminal]
  end
end
