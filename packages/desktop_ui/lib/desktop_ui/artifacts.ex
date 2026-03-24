defmodule DesktopUi.Artifacts do
  @moduledoc """
  Platform artifact workflow placeholder for `desktop_ui`.
  """

  @spec target_platforms() :: [atom()]
  def target_platforms, do: [:windows, :macos, :linux]

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [:platform_builds, :platform_packaging, :runtime_semantics_preservation]
  end

  @spec validation_state() :: atom()
  def validation_state, do: :artifact_boundary_ready
end
