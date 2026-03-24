defmodule DesktopUi.Reference do
  @moduledoc """
  Lightweight package reference helpers for `desktop_ui`.
  """

  @spec package_reference() :: map()
  def package_reference do
    %{
      package: DesktopUi,
      package_areas: DesktopUi.package_areas(),
      widgets: %{
        families: DesktopUi.Widgets.families(),
        modules: DesktopUi.Widgets.modules(),
        contract: DesktopUi.Widget.contract()
      },
      runtime: %{
        assumptions: DesktopUi.Runtime.assumptions(),
        modules: DesktopUi.Runtime.modules(),
        capabilities: DesktopUi.Runtime.capabilities(),
        validation_state: DesktopUi.Runtime.validation_state()
      },
      platform: %{
        targets: DesktopUi.Platform.targets(),
        modules: DesktopUi.Platform.modules(),
        capability_contract: DesktopUi.Platform.capability_contract(),
        validation_state: DesktopUi.Platform.validation_state()
      },
      renderer: %{
        accepts: DesktopUi.Renderer.accepts(),
        responsibilities: DesktopUi.Renderer.responsibilities(),
        validation_state: DesktopUi.Renderer.validation_state()
      },
      transport: %{
        modes: DesktopUi.Transport.modes(),
        integration_points: DesktopUi.Transport.integration_points(),
        validation_state: DesktopUi.Transport.validation_state()
      },
      artifacts: %{
        target_platforms: DesktopUi.Artifacts.target_platforms(),
        responsibilities: DesktopUi.Artifacts.responsibilities(),
        validation_state: DesktopUi.Artifacts.validation_state()
      },
      inspection: %{
        helpers: DesktopUi.Inspection.helpers(),
        package_overview: DesktopUi.Inspection.package_overview()
      },
      tooling: %{
        guides: DesktopUi.Tooling.documentation_surface(),
        workflows: DesktopUi.Tooling.workflows(),
        mix_tasks: DesktopUi.Tooling.mix_tasks()
      }
    }
  end
end
