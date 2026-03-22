defmodule TerminalUi.Reference do
  @moduledoc """
  Lightweight package reference helpers for `terminal_ui`.
  """

  @spec package_reference() :: map()
  def package_reference do
    %{
      package: TerminalUi,
      package_areas: TerminalUi.package_areas(),
      widgets: %{families: TerminalUi.Widgets.families()},
      runtime: %{assumptions: TerminalUi.Runtime.assumptions()},
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
      tooling: %{guides: TerminalUi.Tooling.documentation_surface()}
    }
  end
end
