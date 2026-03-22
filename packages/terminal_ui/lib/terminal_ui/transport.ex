defmodule TerminalUi.Transport do
  @moduledoc """
  Transport boundary placeholder for `terminal_ui`.
  """

  @spec modes() :: [atom()]
  def modes, do: [:native_local, :canonical_boundary]

  @spec integration_points() :: [atom()]
  def integration_points do
    [:runtime, :signals, :boundary_translation]
  end
end
