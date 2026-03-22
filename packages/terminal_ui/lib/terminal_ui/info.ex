defmodule TerminalUi.Info do
  @moduledoc """
  Lightweight package summary helpers.
  """

  @spec package_summary() :: map()
  def package_summary do
    coverage_matrix = TerminalUi.Examples.coverage_matrix()
    validation_report = TerminalUi.Validate.validation_report()

    %{
      package: :terminal_ui,
      namespace: TerminalUi,
      package_areas: TerminalUi.package_areas(),
      validation_state: TerminalUi.Runtime.validation_state(),
      runtime: %{
        assumptions: TerminalUi.Runtime.assumptions(),
        validation_state: TerminalUi.Runtime.validation_state()
      },
      widgets: %{
        families: TerminalUi.Widgets.families(),
        kinds: TerminalUi.Widgets.kinds(),
        validation_state: TerminalUi.Widgets.validation_state()
      },
      backend: %{
        modes: TerminalUi.Backend.modes(),
        selection_contract: TerminalUi.Backend.selection_contract()
      },
      capabilities: %{
        categories: TerminalUi.Capabilities.categories(),
        profiles: TerminalUi.Capabilities.profiles(),
        diagnostics: TerminalUi.Capabilities.diagnostics()
      },
      degradation: %{
        profile: TerminalUi.Capabilities.snapshot().degradation_profile,
        diagnostics: TerminalUi.Degradation.diagnostics()
      },
      style: %{
        primitives: Map.keys(TerminalUi.Style.primitives()),
        hooks: TerminalUi.Style.widget_style_hooks()
      },
      theme: %{
        catalog: TerminalUi.Theme.catalog_ids(),
        default: TerminalUi.Theme.default_theme().id
      },
      inspection: %{
        helpers: TerminalUi.Inspection.helpers()
      },
      renderer: renderer_summary(),
      validation: %{
        workflows: TerminalUi.Tooling.workflows(),
        example_coverage: validation_report.example_coverage.status,
        renderer_determinism: validation_report.renderer_determinism.status,
        runtime_behavior: validation_report.runtime_behavior.status,
        transport_validation: validation_report.transport_validation.status,
        capability_behavior: validation_report.capability_behavior.status,
        tooling_surface: validation_report.tooling_surface.status,
        documentation_surface: validation_report.documentation_surface.status,
        release_readiness: validation_report.release_readiness.status
      },
      continuity: %{
        seams: TerminalUi.Continuity.seams(),
        diagnostic_kinds: TerminalUi.Continuity.diagnostic_kinds()
      },
      transport: %{
        families: TerminalUi.Transport.families(),
        input_families: TerminalUi.Transport.input_families(),
        diagnostics: TerminalUi.Transport.diagnostics()
      },
      layout: %{kinds: TerminalUi.Layout.kinds()},
      layer: %{kinds: TerminalUi.Layer.kinds()},
      examples: %{
        total: length(TerminalUi.Examples.catalog()),
        native_ids: Enum.map(TerminalUi.Examples.native_examples(), & &1.id),
        canonical_ids: Enum.map(TerminalUi.Examples.canonical_examples(), & &1.id),
        comparison_ids:
          TerminalUi.Examples.comparison_examples()
          |> Map.keys()
          |> Enum.sort_by(&to_string/1),
        categories: coverage_matrix.categories |> Map.keys() |> Enum.sort(),
        workflows: coverage_matrix.workflows |> Map.keys() |> Enum.sort(),
        parity_groups: coverage_matrix.parity_groups |> Map.keys() |> Enum.sort()
      },
      documentation: %{
        guides: TerminalUi.Tooling.documentation_surface(),
        preview_surfaces: TerminalUi.Tooling.preview_surfaces()
      },
      tooling: %{
        workflows: TerminalUi.Tooling.workflows(),
        mix_tasks: TerminalUi.Tooling.mix_tasks()
      }
    }
  end

  @spec renderer_summary() :: map()
  def renderer_summary do
    %{
      accepts: TerminalUi.Renderer.accepts(),
      supported_kinds: TerminalUi.Renderer.supported_kinds(),
      responsibilities: TerminalUi.Renderer.responsibilities()
    }
  end

  @spec widget_summary(TerminalUi.Widget.t()) :: map()
  def widget_summary(%TerminalUi.Widget{} = widget) do
    %{
      id: widget.id,
      family: widget.family,
      kind: widget.kind,
      metadata_keys: Map.keys(widget.metadata),
      state_keys: Map.keys(widget.state),
      binding_keys: Map.keys(widget.bindings),
      slots: widget.slots,
      event_keys: Map.keys(widget.events),
      style_keys: Map.keys(widget.styles)
    }
  end
end
