defmodule TerminalUi.Backend do
  @moduledoc """
  Backend selection boundary for `terminal_ui`.
  """

  @spec modes() :: [atom()]
  def modes, do: [:raw, :tty]

  @spec modules() :: [module()]
  def modules, do: []
end
