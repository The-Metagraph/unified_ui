defmodule Mix.Tasks.UnifiedUi.Bench do
  @shortdoc "Runs UnifiedUi benchmark scenarios"
  @moduledoc """
  Runs UnifiedUi performance benchmarks.

  By default this task runs the full baseline benchmark suite in
  `benchmarks/phase5_baseline.exs`.

  ## Options

  - `--quick` - run a short benchmark profile suitable for CI smoke checks
  """
  use Mix.Task

  alias UnifiedUi.MixTasks.Runner

  @benchmark_script "benchmarks/phase5_baseline.exs"
  @switches [quick: :boolean]

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    run_with(args, Runner)
  end

  @doc false
  @spec run_with([String.t()], module()) :: :ok
  def run_with(args, runner_module) do
    {opts, _remaining_args, invalid} = OptionParser.parse(args, strict: @switches)

    case invalid do
      [] ->
        :ok

      invalid_opts ->
        raise Mix.Error,
          message:
            "Unsupported options for mix unified_ui.bench: #{inspect(invalid_opts)}. " <>
              "Supported options: --quick."
    end

    run_args =
      if opts[:quick] do
        [@benchmark_script, "--quick"]
      else
        [@benchmark_script]
      end

    runner_module.run_task("run", run_args)

    :ok
  end
end
