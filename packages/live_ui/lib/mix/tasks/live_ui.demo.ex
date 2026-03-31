defmodule Mix.Tasks.LiveUi.Demo do
  use Mix.Task

  @shortdoc "Prints package-local demo output for live_ui"

  @moduledoc """
  Prints package-local `live_ui` demo output.

      mix live_ui.demo
      mix live_ui.demo native_styled_profile --format html
      mix live_ui.demo styled_continuity_compare --format report
      mix live_ui.demo --format catalog
      mix live_ui.demo --serve
      mix live_ui.demo native_styled_profile --serve --port 4040
  """

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, positional, invalid} =
      OptionParser.parse(args,
        switches: [
          category: :string,
          format: :string,
          host: :string,
          linger_ms: :integer,
          port: :integer,
          serve: :boolean
        ]
      )

    if invalid != [] do
      Mix.raise(usage())
    end

    format = Keyword.get(opts, :format, "summary")
    category = Keyword.get(opts, :category)
    request = request_opts(positional, category)

    if Keyword.get(opts, :serve, false) do
      serve_demo(request,
        host: Keyword.get(opts, :host, LiveUi.Demo.default_host()),
        linger_ms: Keyword.get(opts, :linger_ms),
        port: Keyword.get(opts, :port, LiveUi.Demo.default_port())
      )
    else
      case {format, positional} do
        {"catalog", []} ->
          Mix.shell().info(format_catalog())

        {chosen_format, []} ->
          run_demo(chosen_format, request)

        {chosen_format, ["home"]} ->
          run_demo(chosen_format, request)

        {chosen_format, [_example_id]} ->
          run_demo(chosen_format, request)

        _other ->
          Mix.raise(usage())
      end
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

  defp serve_demo(request, opts) do
    serve_opts =
      request ++
        [
          host: Keyword.fetch!(opts, :host),
          port: Keyword.fetch!(opts, :port)
        ]

    case LiveUi.Demo.serve(serve_opts) do
      {:ok, launch} ->
        Mix.shell().info("""
        LiveUi demo server
          url: #{launch.url}
          press Ctrl+C twice to stop
        """)

        try do
          await_shutdown(Keyword.get(opts, :linger_ms))
        after
          stop_server(launch.server)
        end

      {:error, reason} ->
        Mix.raise("unable to launch live_ui demo server: #{inspect(reason)}")
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

  defp request_opts([], category), do: [category: category]
  defp request_opts(["home"], category), do: [category: category]
  defp request_opts([example_id], category), do: [category: category, example: example_id]
  defp request_opts(_other, _category), do: Mix.raise(usage())

  defp await_shutdown(nil) do
    receive do
    after
      :infinity -> :ok
    end
  end

  defp await_shutdown(milliseconds) when is_integer(milliseconds) and milliseconds >= 0 do
    Process.sleep(milliseconds)
  end

  defp stop_server(server) when is_pid(server) do
    if Process.alive?(server) do
      Supervisor.stop(server)
    end
  end

  defp usage do
    "usage: mix live_ui.demo [home|EXAMPLE_ID] [--format summary|html|report|catalog] [--serve --port PORT --host HOST]"
  end

  defp selected_example_label(nil), do: "none"
  defp selected_example_label(example), do: to_string(example.id)
end
