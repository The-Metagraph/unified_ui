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
        integration: DesktopUi.Platform.diagnostics().integration,
        diagnostics: DesktopUi.Platform.diagnostics(),
        validation_state: DesktopUi.Platform.validation_state()
      },
      layout: %{
        kinds: DesktopUi.Layout.kinds(),
        validation_state: DesktopUi.Layout.validation_state()
      },
      layer: %{
        kinds: DesktopUi.Layer.kinds(),
        validation_state: DesktopUi.Layer.validation_state()
      },
      renderer: %{
        accepts: DesktopUi.Renderer.accepts(),
        responsibilities: DesktopUi.Renderer.responsibilities(),
        validation_state: DesktopUi.Renderer.validation_state()
      },
      transport: %{
        modes: DesktopUi.Transport.modes(),
        families: DesktopUi.Transport.families(),
        input_families: DesktopUi.Transport.input_families(),
        local_default_families: DesktopUi.Transport.local_default_families(),
        boundary_crossing_families: DesktopUi.Transport.boundary_crossing_families(),
        integration_points: DesktopUi.Transport.integration_points(),
        modules: DesktopUi.Transport.modules(),
        diagnostics: DesktopUi.Transport.diagnostics(),
        validation_state: DesktopUi.Transport.validation_state()
      },
      style: %{
        primitives: DesktopUi.Style.primitives(),
        widget_style_hooks: DesktopUi.Style.widget_style_hooks(),
        responsibilities: DesktopUi.Style.responsibilities(),
        validation_state: DesktopUi.Style.validation_state()
      },
      theme: %{
        default_theme: DesktopUi.Theme.default_theme().id,
        catalog_ids: DesktopUi.Theme.catalog_ids(),
        continuity_rules: DesktopUi.Theme.continuity_rules(),
        validation_state: DesktopUi.Theme.validation_state()
      },
      artifacts: %{
        target_platforms: DesktopUi.Artifacts.target_platforms(),
        workflows: DesktopUi.Artifacts.workflows(),
        boundary_policy: DesktopUi.Artifacts.boundary_policy(),
        diagnostics: DesktopUi.Artifacts.diagnostics(),
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
        continuity_contract: DesktopUi.Inspection.continuity_contract(),
        platform_profiles: DesktopUi.Inspection.platform_profiles(),
        shared_runtime_contract: DesktopUi.Inspection.shared_runtime_contract(),
        transport_contract: DesktopUi.Inspection.transport_contract(),
        layering_contract: DesktopUi.Inspection.layering_contract(),
        validation_surface: DesktopUi.Inspection.validation_surface()
      },
      continuity: %{
        seams: DesktopUi.Continuity.seams(),
        diagnostic_kinds: DesktopUi.Continuity.diagnostic_kinds(),
        contract: DesktopUi.Continuity.contract()
      },
      responsibilities: %{
        direct_native: [
          :widgets,
          :layout,
          :layer,
          :runtime,
          :platform,
          :style,
          :theme,
          :continuity
        ],
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
