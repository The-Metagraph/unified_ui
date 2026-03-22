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
      backend: %{modes: TerminalUi.Backend.modes()},
      capabilities: %{categories: TerminalUi.Capabilities.categories()},
      renderer: %{accepts: TerminalUi.Renderer.accepts()},
      transport: %{modes: TerminalUi.Transport.modes()},
      tooling: %{guides: TerminalUi.Tooling.documentation_surface()}
    }
  end
end
