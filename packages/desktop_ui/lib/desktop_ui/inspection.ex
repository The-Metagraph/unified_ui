defmodule DesktopUi.Inspection do
  @moduledoc """
  Lightweight inspection placeholder for `desktop_ui`.
  """

  @spec helpers() :: [atom()]
  def helpers do
    [:package_overview, :shared_runtime_contract, :platform_contract, :validation_surface]
  end

  @spec package_overview() :: map()
  def package_overview do
    %{
      runtime_foundation: :sdl2,
      runtime_binding: :sdl,
      platform_targets: DesktopUi.Platform.targets(),
      package_areas: DesktopUi.package_areas(),
      shared_runtime_contract: shared_runtime_contract(),
      validation: validation_surface()
    }
  end

  @spec shared_runtime_contract() :: map()
  def shared_runtime_contract do
    %{
      assumptions: DesktopUi.Runtime.assumptions(),
      runtime_modules: DesktopUi.Runtime.modules(),
      platform_targets: DesktopUi.Platform.targets(),
      transport_modes: DesktopUi.Transport.modes(),
      direct_native_and_canonical_share_runtime: true
    }
  end

  @spec validation_surface() :: map()
  def validation_surface do
    %{
      widgets: DesktopUi.Widgets.validation_state(),
      runtime: DesktopUi.Runtime.validation_state(),
      platform: DesktopUi.Platform.validation_state(),
      renderer: DesktopUi.Renderer.validation_state(),
      transport: DesktopUi.Transport.validation_state(),
      artifacts: DesktopUi.Artifacts.validation_state()
    }
  end
end
