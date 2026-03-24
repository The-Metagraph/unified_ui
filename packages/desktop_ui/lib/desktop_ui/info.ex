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
        validation_state: DesktopUi.Runtime.validation_state(),
        event_loop:
          DesktopUi.Runtime.EventLoop.diagnostics(DesktopUi.Runtime.EventLoop.scaffold())
      },
      widgets: %{
        families: DesktopUi.Widgets.families(),
        kinds: DesktopUi.Widgets.kinds(),
        contract: DesktopUi.Widget.contract(),
        validation_state: DesktopUi.Widgets.validation_state()
      },
      platform: %{
        targets: DesktopUi.Platform.targets(),
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
        responsibilities: DesktopUi.Renderer.responsibilities(),
        validation_state: DesktopUi.Renderer.validation_state()
      },
      transport: %{
        modes: DesktopUi.Transport.modes(),
        families: DesktopUi.Transport.families(),
        input_families: DesktopUi.Transport.input_families(),
        diagnostics: DesktopUi.Transport.diagnostics(),
        validation_state: DesktopUi.Transport.validation_state()
      },
      style: %{
        primitives: DesktopUi.Style.primitives(),
        validation_state: DesktopUi.Style.validation_state()
      },
      theme: %{
        default_theme: DesktopUi.Theme.default_theme().id,
        catalog_ids: DesktopUi.Theme.catalog_ids(),
        validation_state: DesktopUi.Theme.validation_state()
      },
      artifacts: %{
        target_platforms: DesktopUi.Artifacts.target_platforms(),
        workflows: DesktopUi.Artifacts.workflows(),
        boundary_policy: DesktopUi.Artifacts.boundary_policy(),
        validation_state: DesktopUi.Artifacts.validation_state()
      },
      examples: %{
        native_ids: DesktopUi.Examples.native_ids(),
        canonical_ids: DesktopUi.Examples.canonical_ids(),
        comparison_ids: DesktopUi.Examples.comparison_ids()
      },
      tooling: %{
        guides: DesktopUi.Tooling.documentation_surface(),
        workflows: DesktopUi.Tooling.workflows()
      },
      inspection: %{
        helpers: DesktopUi.Inspection.helpers(),
        validation: DesktopUi.Inspection.validation_surface()
      },
      responsibilities: %{
        direct_native: [:widgets, :layout, :layer, :runtime, :platform, :style, :theme],
        canonical_renderer: [:renderer, :runtime, :transport]
      }
    }
  end
end
