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
        contract: TerminalUi.Capabilities.capability_contract()
      },
      renderer: %{accepts: TerminalUi.Renderer.accepts()},
      transport: %{modes: TerminalUi.Transport.modes()},
      documentation: %{guides: TerminalUi.Tooling.documentation_surface()},
      tooling: %{
        guides: TerminalUi.Tooling.documentation_surface(),
        workflows: TerminalUi.Tooling.workflows()
      }
    }
  end
end
