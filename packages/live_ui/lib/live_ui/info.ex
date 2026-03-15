defmodule LiveUi.Info do
  @moduledoc """
  Lightweight package summary helpers.
  """

  @spec package_summary() :: map()
  def package_summary do
    %{
      package: :live_ui,
      namespace: LiveUi,
      package_areas: LiveUi.package_areas()
    }
  end
end
