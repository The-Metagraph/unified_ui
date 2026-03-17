defmodule Mix.Tasks.Examples.Launch do
  use Mix.Task

  @shortdoc "Launches one standalone example app through mix phx.server"

  @moduledoc """
  Launches one standalone example app through `mix phx.server`.

      mix examples.launch button --dry-run
      mix examples.launch button --smoke-test
      mix examples.launch overlay --port 4104
  """

  alias UnifiedExamples.Shared.{AggregateDemo, Tooling}

  @impl Mix.Task
  def run(args) do
    {opts, positional, _invalid} =
      OptionParser.parse(args,
        switches: [dry_run: :boolean, smoke_test: :boolean, port: :integer]
      )

    dry_run? = Keyword.get(opts, :dry_run, false)
    smoke_test? = Keyword.get(opts, :smoke_test, false)
    launch_opts = Keyword.take(opts, [:port])

    case positional do
      [directory] ->
        descriptor = launch_descriptor(directory, launch_opts)

        cond do
          dry_run? ->
            Mix.shell().info(
              [
                "Example launch descriptor",
                "directory: #{descriptor.directory}",
                "url: #{descriptor.url}",
                "launch_command: #{descriptor.command}"
              ]
              |> Enum.join("\n")
            )

          smoke_test? ->
            case Tooling.smoke_launch(directory, launch_opts) do
              {:ok, smoke} ->
                Mix.shell().info(
                  [
                    "Example launch smoke test",
                    "directory: #{smoke.directory}",
                    "status: #{smoke.status}",
                    "url: #{smoke.url}",
                    "launch_command: #{smoke.launch_command}",
                    "body_bytes: #{byte_size(smoke.body)}"
                  ]
                  |> Enum.join("\n")
                )

              {:error, reason} ->
                Mix.raise("example launch smoke test failed: #{inspect(reason)}")
            end

          true ->
            [program | argv] = descriptor.argv

            System.cmd(program, argv,
              cd: descriptor.cwd,
              env: descriptor.env,
              into: IO.stream(:stdio, :line),
              stderr_to_stdout: true
            )
        end

      _ ->
        Mix.raise("usage: mix examples.launch DIRECTORY [--port PORT] [--dry-run] [--smoke-test]")
    end
  end

  defp launch_descriptor("demo", opts), do: AggregateDemo.launch_descriptor(opts)
  defp launch_descriptor(:demo, opts), do: AggregateDemo.launch_descriptor(opts)
  defp launch_descriptor(directory, opts), do: Tooling.launch_descriptor(directory, opts)
end
