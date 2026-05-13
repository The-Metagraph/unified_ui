defmodule Mix.Tasks.LiveUi.Export do
  use Mix.Task

  @shortdoc "Prints a stable exported representation of a maintained live_ui example"

  @moduledoc """
  Prints a stable exported representation of a maintained `live_ui` example.

      mix live_ui.export native_styled_profile
      mix live_ui.export native_styled_profile --format artifact
      mix live_ui.export canonical_styled_operations --format html
      mix live_ui.export native_styled_profile --format comparison
      mix live_ui.export native_styled_profile --format style
      mix live_ui.export --format portable_widgets
      mix live_ui.export --format catalog
  """

  alias LiveUi.Export

  @impl Mix.Task
  def run(args) do
    {opts, positional, _invalid} = OptionParser.parse(args, switches: [format: :string])
    format = Keyword.get(opts, :format, "report")

    case {format, positional} do
      {"catalog", _} ->
        Mix.shell().info(Export.catalog())

      {"portable_widgets", _} ->
        Mix.shell().info(
          LiveUi.Tooling.portable_widget_report()
          |> Kernel.inspect(pretty: true, width: 100, limit: :infinity, sort_maps: true)
        )

      {chosen_format, [example_id]} ->
        export_format =
          case chosen_format do
            "metadata" -> :metadata
            "report" -> :report
            "portable_widgets" -> :portable_widgets
            "html" -> :html
            "comparison" -> :comparison
            "diagnostics" -> :diagnostics
            "style" -> :style
            "artifact" -> :artifact
            other -> Mix.raise("unsupported export format #{inspect(other)}")
          end

        case Export.example(example_id, export_format) do
          {:ok, output} ->
            Mix.shell().info(output)

          {:error, reason} ->
            Mix.raise("unable to export example #{inspect(example_id)}: #{inspect(reason)}")
        end

      _ ->
        Mix.raise(
          "usage: mix live_ui.export [EXAMPLE_ID] [--format metadata|report|portable_widgets|html|comparison|diagnostics|style|artifact|catalog]"
        )
    end
  end
end
