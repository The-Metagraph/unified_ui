defmodule TerminalUi.Reference do
  @moduledoc """
  Lightweight package reference helpers for `terminal_ui`.
  """

  @spec example_summary() :: map()
  def example_summary do
    %{
      catalog: TerminalUi.Examples.catalog(),
      native_ids: Enum.map(TerminalUi.Examples.native_examples(), & &1.id),
      canonical_ids: Enum.map(TerminalUi.Examples.canonical_examples(), & &1.id),
      mixed_ids: Enum.map(TerminalUi.Examples.mixed_examples(), & &1.id),
      comparison_ids:
        TerminalUi.Examples.comparison_examples()
        |> Map.keys()
        |> Enum.sort_by(&to_string/1),
      coverage_matrix: TerminalUi.Examples.coverage_matrix()
    }
  end

  @spec capability_summary() :: map()
  def capability_summary do
    %{
      categories: TerminalUi.Capabilities.categories(),
      profiles: TerminalUi.Capabilities.profiles(),
      diagnostics: TerminalUi.Capabilities.diagnostics(),
      degradation: TerminalUi.Degradation.diagnostics()
    }
  end

  @spec shared_runtime_contract() :: map()
  def shared_runtime_contract do
    %{
      assumptions: TerminalUi.Runtime.assumptions(),
      backend_modes: TerminalUi.Backend.modes(),
      capability_profiles: TerminalUi.Capabilities.profiles(),
      renderer_accepts: TerminalUi.Renderer.accepts(),
      transport_modes: TerminalUi.Transport.modes(),
      direct_native_and_canonical_share_runtime: true
    }
  end

  @spec package_reference() :: map()
  def package_reference do
    %{
      package: TerminalUi,
      package_areas: TerminalUi.package_areas(),
      widgets: %{
        families: TerminalUi.Widgets.families(),
        kinds: TerminalUi.Widgets.kinds(),
        modules: TerminalUi.Widgets.modules(),
        contract: TerminalUi.Widget.contract(),
        validation_state: TerminalUi.Widgets.validation_state()
      },
      runtime: %{
        assumptions: TerminalUi.Runtime.assumptions(),
        modules: TerminalUi.Runtime.modules(),
        capabilities: TerminalUi.Runtime.capabilities(),
        validation_state: TerminalUi.Runtime.validation_state()
      },
      backend: %{
        modes: TerminalUi.Backend.modes(),
        modules: TerminalUi.Backend.modules(),
        selection_contract: TerminalUi.Backend.selection_contract(),
        callback_contract: TerminalUi.Backend.callback_contract()
      },
      capabilities: %{
        categories: TerminalUi.Capabilities.categories(),
        profiles: TerminalUi.Capabilities.profiles(),
        contract: TerminalUi.Capabilities.capability_contract(),
        diagnostics: TerminalUi.Capabilities.diagnostics()
      },
      degradation: %{
        modules: TerminalUi.Degradation.modules(),
        responsibilities: TerminalUi.Degradation.responsibilities(),
        diagnostics: TerminalUi.Degradation.diagnostics()
      },
      style: %{
        primitives: TerminalUi.Style.primitives(),
        hooks: TerminalUi.Style.widget_style_hooks(),
        responsibilities: TerminalUi.Style.responsibilities()
      },
      theme: %{
        catalog: TerminalUi.Theme.catalog_ids(),
        default: TerminalUi.Theme.default_theme().id,
        continuity_rules: TerminalUi.Theme.continuity_rules()
      },
      inspection: %{
        helpers: TerminalUi.Inspection.helpers(),
        package_overview: TerminalUi.Inspection.package_overview()
      },
      continuity: %{
        seams: TerminalUi.Continuity.seams(),
        contract: TerminalUi.Continuity.contract()
      },
      layout: %{kinds: TerminalUi.Layout.kinds(), module: TerminalUi.Layout},
      layer: %{kinds: TerminalUi.Layer.kinds(), module: TerminalUi.Layer},
      renderer: %{
        accepts: TerminalUi.Renderer.accepts(),
        supported_kinds: TerminalUi.Renderer.supported_kinds(),
        required_canonical_kinds: TerminalUi.Renderer.required_canonical_kinds(),
        responsibilities: TerminalUi.Renderer.responsibilities(),
        mapper: TerminalUi.Renderer.Mapper
      },
      transport: %{
        modes: TerminalUi.Transport.modes(),
        families: TerminalUi.Transport.families(),
        input_families: TerminalUi.Transport.input_families(),
        local_default_families: TerminalUi.Transport.local_default_families(),
        boundary_crossing_families: TerminalUi.Transport.boundary_crossing_families(),
        modules: TerminalUi.Transport.modules(),
        diagnostics: TerminalUi.Transport.diagnostics()
      },
      validation: %{
        inspect: TerminalUi.Inspect,
        validate: TerminalUi.Validate,
        validation_sections:
          TerminalUi.Validate.validation_report()
          |> Map.keys()
          |> Enum.sort(),
        release_readiness_modes: [:summary, :strict],
        release_gates: TerminalUi.Validate.release_gates(),
        evolution_rules: TerminalUi.Validate.evolution_rules()
      },
      examples: example_summary(),
      documentation: %{
        guides: TerminalUi.Tooling.documentation_surface(),
        maintainer_commands: TerminalUi.Tooling.mix_tasks(),
        shared_runtime_contract: shared_runtime_contract()
      },
      tooling: %{
        guides: TerminalUi.Tooling.documentation_surface(),
        workflows: TerminalUi.Tooling.workflows(),
        preview_surfaces: TerminalUi.Tooling.preview_surfaces()
      },
      summaries: %{
        examples: example_summary(),
        capabilities: capability_summary()
      }
    }
  end
end
