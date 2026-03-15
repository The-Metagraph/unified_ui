defmodule Mix.Tasks.Examples.Run do
  use Mix.Task

  @shortdoc "Runs one standalone example-app workflow"

  @moduledoc """
  Runs one standalone example-app workflow.

      mix examples.run button
      mix examples.run overlay --dry-run
  """

  alias UnifiedExamples.Shared.Tooling

  @impl Mix.Task
  def run(args) do
    {opts, positional, _invalid} = OptionParser.parse(args, switches: [dry_run: :boolean])
    dry_run? = Keyword.get(opts, :dry_run, false)

    case positional do
      [directory] ->
        descriptor = Tooling.run_descriptor(directory)

        if dry_run? do
          Mix.shell().info(descriptor.command)
        else
          case Tooling.run(directory) do
            {:ok, output} ->
              Mix.shell().info(output)

            {:error, %{status: status, output: output}} ->
              Mix.raise("example run failed with status #{status}:\n#{output}")
          end
        end

      _ ->
        Mix.raise("usage: mix examples.run DIRECTORY [--dry-run]")
    end
  end
end
