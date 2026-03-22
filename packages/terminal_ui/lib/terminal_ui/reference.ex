defmodule TerminalUi.Reference do
  @moduledoc """
  Lightweight package reference helpers for `terminal_ui`.
  """

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
      layout: %{kinds: TerminalUi.Layout.kinds(), module: TerminalUi.Layout},
      layer: %{kinds: TerminalUi.Layer.kinds(), module: TerminalUi.Layer},
      renderer: %{
        accepts: TerminalUi.Renderer.accepts(),
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
      examples: %{
        native_ids: Enum.map(TerminalUi.Examples.native_examples(), & &1.id),
        canonical_ids: Enum.map(TerminalUi.Examples.canonical_examples(), & &1.id),
        comparison_ids:
          TerminalUi.Examples.comparison_examples()
          |> Map.keys()
          |> Enum.sort_by(&to_string/1),
        coverage_matrix: TerminalUi.Examples.coverage_matrix()
      },
      documentation: %{guides: TerminalUi.Tooling.documentation_surface()},
      tooling: %{
        guides: TerminalUi.Tooling.documentation_surface(),
        workflows: TerminalUi.Tooling.workflows()
      }
    }
  end
end
