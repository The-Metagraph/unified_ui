defmodule Mix.Tasks.DesktopUi.Run do
  use Mix.Task

  @shortdoc "Runs a host-backed desktop_ui example through the SDL3 adapter seam"

  @moduledoc """
  Runs a maintained `desktop_ui` example through the host-backed SDL3 adapter
  seam and prints the execution diagnostics.

      mix desktop_ui.run --format catalog
      mix desktop_ui.run native_foundational
      mix desktop_ui.run canonical_foundational --format report
  """

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")
    {opts, positional, _invalid} = OptionParser.parse(args, switches: [format: :string])
    format = Keyword.get(opts, :format, "summary")

    case {format, positional} do
      {"catalog", _} ->
        Mix.shell().info(
          Kernel.inspect(DesktopUi.Tooling.run_catalog(),
            pretty: true,
            width: 100,
            limit: :infinity,
            sort_maps: true
          )
        )

      {chosen_format, [example_id]} ->
        case DesktopUi.Tooling.run_example(example_id) do
          {:ok, execution} ->
            Mix.shell().info(format_execution(execution, chosen_format))

          {:error, reason} ->
            Mix.raise("unable to run example #{inspect(example_id)}: #{inspect(reason)}")
        end

      _ ->
        Mix.raise(
          "usage: mix desktop_ui.run [EXAMPLE_ID] [--format summary|report|catalog]"
        )
    end
  end

  defp format_execution(execution, "summary") do
    [
      "DesktopUi host execution summary",
      "  example: #{execution.id}",
      "  category: #{execution.metadata.category}",
      "  host state: #{execution.host_status.state}",
      "  presented frame?: #{execution.frame.payload.presentation.presented_frame?}",
      "  presented frames: #{execution.frame.payload.host.presented_frames}",
      "  shutdown state: #{execution.shutdown.final_state}"
    ]
    |> Enum.join("\n")
  end

  defp format_execution(execution, "report") do
    Kernel.inspect(execution, pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end

  defp format_execution(_execution, other) do
    Mix.raise("unsupported run format #{inspect(other)}")
  end
end
