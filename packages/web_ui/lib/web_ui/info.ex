defmodule WebUi.Info do
  @moduledoc """
  Summary helpers for the `web_ui` package scaffold.
  """

  @spec package_summary() :: map()
  def package_summary do
    %{
      package: WebUi.package_identity(),
      runtime_split?: WebUi.Runtime.split?(),
      module_area_names: WebUi.module_areas() |> Map.keys() |> Enum.sort(),
      assumptions: WebUi.Runtime.assumptions(),
      tooling: WebUi.Tooling.capabilities()
    }
  end
end
