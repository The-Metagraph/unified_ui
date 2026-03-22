defmodule TerminalUi.Info do
  @moduledoc """
  Lightweight package summary helpers.
  """

  @spec package_summary() :: map()
  def package_summary do
    coverage_matrix = TerminalUi.Examples.coverage_matrix()

    %{
      package: :terminal_ui,
      namespace: TerminalUi,
      package_areas: TerminalUi.package_areas(),
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
      transport: %{
        families: TerminalUi.Transport.families(),
        input_families: TerminalUi.Transport.input_families(),
        diagnostics: TerminalUi.Transport.diagnostics()
      },
      layout: %{kinds: TerminalUi.Layout.kinds()},
      layer: %{kinds: TerminalUi.Layer.kinds()},
      examples: %{
        native_ids: Enum.map(TerminalUi.Examples.native_examples(), & &1.id),
        canonical_ids: Enum.map(TerminalUi.Examples.canonical_examples(), & &1.id),
        comparison_ids:
          TerminalUi.Examples.comparison_examples()
          |> Map.keys()
          |> Enum.sort_by(&to_string/1),
        categories: coverage_matrix.categories |> Map.keys() |> Enum.sort(),
        workflows: coverage_matrix.workflows |> Map.keys() |> Enum.sort()
      },
      documentation: %{guides: TerminalUi.Tooling.documentation_surface()},
      tooling: %{workflows: TerminalUi.Tooling.workflows()}
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
