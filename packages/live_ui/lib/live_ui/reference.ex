defmodule LiveUi.Reference do
  @moduledoc """
  Reference helpers for package boundaries and capabilities.
  """

  @spec package_reference() :: map()
  def package_reference do
    %{
      package: LiveUi,
      widgets: LiveUi.Widgets.families(),
      runtime: LiveUi.Runtime.capabilities(),
      renderer: LiveUi.Renderer.accepts(),
      transport: LiveUi.Transport.modes(),
      tooling: LiveUi.Tooling.workflows()
    }
  end
end
