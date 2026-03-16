defmodule Mix.Tasks.Examples.Launch do
  use Mix.Task

  @shortdoc "Launches one standalone example app through mix phx.server"

  @moduledoc """
  Launches one standalone example app through `mix phx.server`.

      mix examples.launch button --dry-run
      mix examples.launch overlay --port 4104
  """

  alias UnifiedExamples.Shared.Tooling

  @impl Mix.Task
  def run(args) do
    {opts, positional, _invalid} =
      OptionParser.parse(args, switches: [dry_run: :boolean, port: :integer])

    dry_run? = Keyword.get(opts, :dry_run, false)
    launch_opts = Keyword.take(opts, [:port])

    case positional do
      [directory] ->
        descriptor = Tooling.launch_descriptor(directory, launch_opts)

        if dry_run? do
          Mix.shell().info(descriptor.command)
        else
          [program | argv] = descriptor.argv

          System.cmd(program, argv,
            cd: descriptor.cwd,
            env: descriptor.env,
            into: IO.stream(:stdio, :line),
            stderr_to_stdout: true
          )
        end

      _ ->
        Mix.raise("usage: mix examples.launch DIRECTORY [--port PORT] [--dry-run]")
    end
  end
end
