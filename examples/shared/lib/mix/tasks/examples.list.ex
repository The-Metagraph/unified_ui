defmodule Mix.Tasks.Examples.List do
  use Mix.Task

  @shortdoc "Prints the standalone example-app catalog"

  @moduledoc """
  Prints the standalone example-app catalog.

      mix examples.list
  """

  alias UnifiedExamples.Shared.Tooling

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info(Tooling.catalog_report())
  end
end
