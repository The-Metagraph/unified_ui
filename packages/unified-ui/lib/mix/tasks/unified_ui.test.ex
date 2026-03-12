defmodule Mix.Tasks.UnifiedUi.Test do
  @shortdoc "Runs UnifiedUi tests with optional strict checks"
  @moduledoc """
  Runs the UnifiedUi test suite.

  By default this task runs:

  - `mix test`

  ## Options

  - `--cover` - run tests with coverage reporting (`mix test --cover`)
  - `--strict` - run `mix credo --strict` after tests
  """
  use Mix.Task

  alias UnifiedUi.MixTasks.Runner

  @switches [cover: :boolean, strict: :boolean]

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    run_with(args, Runner)
  end

  @doc false
  @spec run_with([String.t()], module()) :: :ok
  def run_with(args, runner_module) do
    {opts, test_args, invalid} = OptionParser.parse(args, strict: @switches)

    case invalid do
      [] ->
        :ok

      invalid_opts ->
        raise Mix.Error,
          message:
            "Unsupported options for mix unified_ui.test: #{inspect(invalid_opts)}. " <>
              "Supported options: --cover, --strict."
    end

    test_args =
      if opts[:cover] do
        ["--cover" | test_args]
      else
        test_args
      end

    runner_module.run_task("test", test_args)

    if opts[:strict] do
      runner_module.run_task("credo", ["--strict"])
    end

    :ok
  end
end
