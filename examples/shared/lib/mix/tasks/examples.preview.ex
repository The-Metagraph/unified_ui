defmodule Mix.Tasks.Examples.Preview do
  use Mix.Task

  @shortdoc "Prints preview output for one standalone example app"

  @moduledoc """
  Prints preview output for one standalone example app.

      mix examples.preview button
      mix examples.preview overlay --format html
      mix examples.preview cluster_dashboard --format metadata
  """

  alias UnifiedExamples.Shared.Tooling

  @impl Mix.Task
  def run(args) do
    {opts, positional, _invalid} = OptionParser.parse(args, switches: [format: :string])
    format = parse_format(Keyword.get(opts, :format, "report"))

    case positional do
      [directory] ->
        case Tooling.preview(directory, format) do
          {:ok, output} when is_binary(output) ->
            Mix.shell().info(output)

          {:ok, output} ->
            Mix.shell().info(Kernel.inspect(output, pretty: true, width: 100, limit: :infinity))

          {:error, reason} ->
            Mix.raise("unable to preview #{inspect(directory)}: #{inspect(reason)}")
        end

      _ ->
        Mix.raise(
          "usage: mix examples.preview DIRECTORY [--format report|html|metadata|inspection]"
        )
    end
  end

  defp parse_format("report"), do: :report
  defp parse_format("html"), do: :html
  defp parse_format("metadata"), do: :metadata
  defp parse_format("inspection"), do: :inspection
  defp parse_format(other), do: Mix.raise("unsupported preview format #{inspect(other)}")
end
