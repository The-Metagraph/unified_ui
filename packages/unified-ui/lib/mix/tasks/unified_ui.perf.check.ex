defmodule Mix.Tasks.UnifiedUi.Perf.Check do
  @shortdoc "Runs UnifiedUi performance budget checks"
  @moduledoc """
  Runs deterministic performance budget checks for UnifiedUi.

  This task executes `benchmarks/phase5_budget_check.exs` and fails when
  measured timings exceed the configured regression budgets.

  ## Options

  - `--quick` - run a shorter budget check profile suitable for CI
  """
  use Mix.Task

  alias UnifiedUi.MixTasks.Runner

  @budget_script "benchmarks/phase5_budget_check.exs"
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
            "Unsupported options for mix unified_ui.perf.check: #{inspect(invalid_opts)}. " <>
              "Supported options: --quick."
    end

    run_args =
      if opts[:quick] do
        [@budget_script, "--quick"]
      else
        [@budget_script]
      end

    runner_module.run_task("run", run_args)

    :ok
  end
end
