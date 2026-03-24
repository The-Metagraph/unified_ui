defmodule DesktopUi.Info do
  @moduledoc """
  Lightweight package summary helpers for `desktop_ui`.
  """

  @spec package_summary() :: map()
  def package_summary do
    %{
      package: :desktop_ui,
      namespace: DesktopUi,
      package_areas: DesktopUi.package_areas(),
      runtime: %{
        assumptions: DesktopUi.Runtime.assumptions(),
        validation_state: DesktopUi.Runtime.validation_state()
      },
      widgets: %{
        families: DesktopUi.Widgets.families(),
        contract: DesktopUi.Widget.contract()
      },
      platform: %{
        targets: DesktopUi.Platform.targets(),
        validation_state: DesktopUi.Platform.validation_state()
      },
      renderer: %{
        responsibilities: DesktopUi.Renderer.responsibilities(),
        validation_state: DesktopUi.Renderer.validation_state()
      },
      transport: %{
        modes: DesktopUi.Transport.modes(),
        validation_state: DesktopUi.Transport.validation_state()
      },
      artifacts: %{
        target_platforms: DesktopUi.Artifacts.target_platforms(),
        validation_state: DesktopUi.Artifacts.validation_state()
      },
      tooling: %{
        guides: DesktopUi.Tooling.documentation_surface(),
        workflows: DesktopUi.Tooling.workflows()
      }
    }
  end
end
