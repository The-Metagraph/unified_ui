defmodule DesktopUi.Platform do
  @moduledoc """
  Platform integration boundary placeholder for `desktop_ui`.
  """

  @type target :: :windows | :macos | :linux

  @spec targets() :: [target()]
  def targets, do: [:windows, :macos, :linux]

  @spec modules() :: [module()]
  def modules do
    [__MODULE__]
  end

  @spec capability_contract() :: map()
  def capability_contract do
    %{
      shared_categories: [:windowing, :menus, :shortcuts, :notifications],
      target_specific_callbacks: [:lifecycle, :focus, :file_open, :window_management]
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :adapter_scaffold_ready
end
