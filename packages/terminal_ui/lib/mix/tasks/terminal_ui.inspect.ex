defmodule Mix.Tasks.TerminalUi.Inspect do
  use Mix.Task

  @shortdoc "Prints inspection output for a maintained terminal_ui example"

  @moduledoc """
  Prints inspection output for a maintained `terminal_ui` example.

      mix terminal_ui.inspect native_styled_review
      mix terminal_ui.inspect canonical_styled_review --format diagnostics
      mix terminal_ui.inspect styled_continuity_review --format comparison
      mix terminal_ui.inspect --format catalog
  """

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")
    {opts, positional, _invalid} = OptionParser.parse(args, switches: [format: :string])
    format = Keyword.get(opts, :format, "report")

    case {format, positional} do
      {"catalog", _} ->
        Mix.shell().info(
          Kernel.inspect(TerminalUi.Inspect.catalog(),
            pretty: true,
            width: 100,
            limit: :infinity,
            sort_maps: true
          )
        )

      {chosen_format, [example_id]} ->
        inspect_format =
          case chosen_format do
            "report" -> :report
            "metadata" -> :metadata
            "comparison" -> :comparison
            "diagnostics" -> :diagnostics
            other -> Mix.raise("unsupported inspect format #{inspect(other)}")
          end

        case TerminalUi.Inspect.render(example_id, inspect_format) do
          {:ok, output} ->
            Mix.shell().info(output)

          {:error, reason} ->
            Mix.raise("unable to inspect example #{inspect(example_id)}: #{inspect(reason)}")
        end

      _ ->
        Mix.raise(
          "usage: mix terminal_ui.inspect [EXAMPLE_ID] [--format report|metadata|comparison|diagnostics|catalog]"
        )
    end
  end
end
