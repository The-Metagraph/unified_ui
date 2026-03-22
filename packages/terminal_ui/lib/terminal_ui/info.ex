defmodule TerminalUi.Info do
  @moduledoc """
  Lightweight package summary helpers.
  """

  @spec package_summary() :: map()
  def package_summary do
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
        kinds: TerminalUi.Widgets.kinds()
      },
      backend: %{
        modes: TerminalUi.Backend.modes(),
        selection_contract: TerminalUi.Backend.selection_contract()
      },
      capabilities: %{
        categories: TerminalUi.Capabilities.categories(),
        profiles: TerminalUi.Capabilities.profiles()
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
      slots: widget.slots,
      event_keys: Map.keys(widget.events),
      style_keys: Map.keys(widget.styles)
    }
  end
end
