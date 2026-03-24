defmodule DesktopUi.Inspection do
  @moduledoc """
  Lightweight inspection placeholder for `desktop_ui`.
  """

  @spec helpers() :: [atom()]
  def helpers do
    [:package_overview, :runtime_contract, :platform_contract]
  end

  @spec package_overview() :: map()
  def package_overview do
    %{
      runtime_foundation: :sdl2,
      platform_targets: DesktopUi.Platform.targets(),
      package_areas: DesktopUi.package_areas()
    }
  end
end
