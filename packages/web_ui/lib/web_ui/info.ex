defmodule WebUi.Info do
  @moduledoc """
  Package introspection and summary helpers for web_ui.
  """

  @doc """
  Returns a summary of the web_ui package state and capabilities.
  """
  @spec package_summary() :: map()
  def package_summary do
    %{
      package: :web_ui,
      version: "0.1.0",
      runtime: :phoenix_elm_split,
      areas: WebUi.package_areas(),
      description: "Phoenix + Elm runtime library for the unified ecosystem."
    }
  end
end
