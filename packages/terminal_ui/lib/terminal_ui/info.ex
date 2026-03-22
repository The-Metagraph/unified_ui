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
      runtime: %{assumptions: TerminalUi.Runtime.assumptions()},
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
end
