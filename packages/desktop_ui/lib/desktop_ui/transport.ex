defmodule DesktopUi.Transport do
  @moduledoc """
  Transport boundary placeholder for desktop-local and canonical-boundary
  events.
  """

  @spec modes() :: [atom()]
  def modes, do: [:native_local, :canonical_boundary]

  @spec integration_points() :: [atom()]
  def integration_points do
    [:runtime, :platform_input_normalization, :canonical_signal_translation]
  end

  @spec validation_state() :: atom()
  def validation_state, do: :boundary_scaffold_ready
end
