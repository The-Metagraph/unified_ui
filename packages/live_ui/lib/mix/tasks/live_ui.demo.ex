defmodule Mix.Tasks.LiveUi.Demo do
  use Mix.Task

  @shortdoc "Prints package-local demo output for live_ui"

  @moduledoc """
  Prints package-local `live_ui` demo output.

      mix live_ui.demo
      mix live_ui.demo native_styled_profile --format html
      mix live_ui.demo styled_continuity_compare --format report
      mix live_ui.demo --format catalog
  """

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, positional, invalid} =
      OptionParser.parse(args, switches: [format: :string, category: :string])

    if invalid != [] do
      Mix.raise("usage: mix live_ui.demo [home|EXAMPLE_ID] [--format summary|html|report|catalog]")
    end

    format = Keyword.get(opts, :format, "summary")
    category = Keyword.get(opts, :category)

    case {format, positional} do
      {"catalog", []} ->
        Mix.shell().info(format_catalog())

      {chosen_format, []} ->
        run_demo(chosen_format, [category: category])

      {chosen_format, ["home"]} ->
        run_demo(chosen_format, [category: category])

      {chosen_format, [example_id]} ->
        run_demo(chosen_format, [category: category, example: example_id])

      _other ->
        Mix.raise("usage: mix live_ui.demo [home|EXAMPLE_ID] [--format summary|html|report|catalog]")
    end
  end

  defp run_demo(format, opts) do
    case LiveUi.Demo.run(opts) do
      {:ok, execution} ->
        Mix.shell().info(format_execution(execution, format))

      {:error, reason} ->
        Mix.raise("unable to render live_ui demo: #{inspect(reason)}")
    end
  end

  defp format_execution(execution, "summary") do
    [
      "LiveUi demo summary",
      "  view: #{execution.view}",
      "  category: #{execution.selected_category}",
      "  selected example: #{selected_example_label(execution.selected_example)}",
      "  examples in lane: #{length(execution.examples)}",
      "  total examples: #{execution.total_examples}"
    ]
    |> Enum.join("\n")
  end

  defp format_execution(execution, "html"), do: execution.html

  defp format_execution(execution, "report") do
    inspect(execution, pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end

  defp format_execution(_execution, other) do
    Mix.raise("unsupported demo format #{inspect(other)}")
  end

  defp format_catalog do
    LiveUi.Demo.catalog()
    |> inspect(pretty: true, width: 100, limit: :infinity, sort_maps: true)
  end

  defp selected_example_label(nil), do: "none"
  defp selected_example_label(example), do: to_string(example.id)
end

