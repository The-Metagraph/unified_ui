defmodule WebUi.Reference do
  @moduledoc """
  Reference helpers for the `web_ui` package scaffold.
  """

  @spec package_reference() :: map()
  def package_reference do
    %{
      package: WebUi.package_identity(),
      module_areas: WebUi.module_areas(),
      runtime: WebUi.Runtime.sides(),
      widgets: WebUi.Widgets.responsibilities(),
      renderer: WebUi.Renderer.responsibilities(),
      transport: WebUi.Transport.responsibilities()
    }
  end
end
