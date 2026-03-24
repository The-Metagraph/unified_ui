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
        kinds: DesktopUi.Widgets.kinds(),
        modules: DesktopUi.Widgets.modules(),
        contract: DesktopUi.Widget.contract(),
        registration_model: DesktopUi.Widgets.registration_model(),
        validation_state: DesktopUi.Widgets.validation_state()
      },
      runtime: %{
        assumptions: DesktopUi.Runtime.assumptions(),
        modules: DesktopUi.Runtime.modules(),
        capabilities: DesktopUi.Runtime.capabilities(),
        validation_state: DesktopUi.Runtime.validation_state(),
        event_loop_diagnostics:
          DesktopUi.Runtime.EventLoop.diagnostics(DesktopUi.Runtime.EventLoop.scaffold())
      },
      platform: %{
        targets: DesktopUi.Platform.targets(),
        modules: DesktopUi.Platform.modules(),
        capability_contract: DesktopUi.Platform.capability_contract(),
        callback_contract: DesktopUi.Platform.callback_contract(),
        diagnostics: DesktopUi.Platform.diagnostics(),
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
      examples: %{
        native_ids: DesktopUi.Examples.native_ids(),
        canonical_ids: DesktopUi.Examples.canonical_ids(),
        comparison_ids: DesktopUi.Examples.comparison_ids()
      },
      inspection: %{
        helpers: DesktopUi.Inspection.helpers(),
        package_overview: DesktopUi.Inspection.package_overview(),
        shared_runtime_contract: DesktopUi.Inspection.shared_runtime_contract(),
        validation_surface: DesktopUi.Inspection.validation_surface()
      },
      responsibilities: %{
        direct_native: [:widgets, :runtime, :platform],
        canonical_renderer: [:renderer, :runtime, :transport],
        bounded_platform_variation: true
      },
      tooling: %{
        guides: DesktopUi.Tooling.documentation_surface(),
        workflows: DesktopUi.Tooling.workflows(),
        mix_tasks: DesktopUi.Tooling.mix_tasks()
      }
    }
  end
end
