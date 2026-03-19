defmodule WebUi.Reference do
  @moduledoc """
  Package reference surfaces for web_ui.

  Provides helpers for discovering and understanding the package's
  widget families, runtime modules, and integration points.
  """

  @doc """
  Returns the package reference map describing all public modules and their responsibilities.
  """
  @spec package_reference() :: map()
  def package_reference do
    %{
      widgets: %{
        description: "Native widget modules for direct web_ui use",
        modules: []
      },
      server_runtime: %{
        description: "Phoenix server-side runtime entrypoints",
        modules: []
      },
      frontend_runtime: %{
        description: "Elm client-side runtime modules",
        modules: []
      },
      renderer: %{
        description: "Canonical IUR to Phoenix + Elm rendering",
        modules: []
      },
      transport: %{
        description: "Signal transport and browser bridge",
        modules: []
      },
      tooling: %{
        description: "Development and maintenance helpers",
        modules: []
      }
    }
  end
end
