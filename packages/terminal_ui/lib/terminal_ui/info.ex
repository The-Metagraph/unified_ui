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
      backend: %{modes: TerminalUi.Backend.modes()},
      capabilities: %{categories: TerminalUi.Capabilities.categories()},
      documentation: %{guides: TerminalUi.Tooling.documentation_surface()},
      tooling: %{workflows: TerminalUi.Tooling.workflows()}
    }
  end
end
