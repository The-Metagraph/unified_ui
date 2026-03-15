defmodule Mix.Tasks.LiveUi.Preview do
  use Mix.Task

  @shortdoc "Prints preview output for a maintained live_ui example"

  @moduledoc """
  Prints preview output for a maintained `live_ui` example.

      mix live_ui.preview
      mix live_ui.preview native_styled_profile
      mix live_ui.preview canonical_styled_operations --format html
      mix live_ui.preview styled_continuity_compare --format report
  """

  alias LiveUi.Export

  @impl Mix.Task
  def run(args) do
    {opts, positional, _invalid} = OptionParser.parse(args, switches: [format: :string])
    format = Keyword.get(opts, :format, "report")

    case positional do
      [] ->
        Mix.shell().info(Export.catalog())

      [example_id] ->
        export_format =
          case format do
            "report" -> :report
            "html" -> :html
            "metadata" -> :metadata
            other -> Mix.raise("unsupported preview format #{inspect(other)}")
          end

        case Export.example(example_id, export_format) do
          {:ok, output} ->
            Mix.shell().info(output)

          {:error, reason} ->
            Mix.raise("unable to preview example #{inspect(example_id)}: #{inspect(reason)}")
        end

      _ ->
        Mix.raise("usage: mix live_ui.preview [EXAMPLE_ID] [--format report|html|metadata]")
    end
  end
end
