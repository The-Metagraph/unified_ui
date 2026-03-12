defmodule Mix.Tasks.UnifiedUi.Format do
  @shortdoc "Formats UnifiedUi code with optional check mode"
  @moduledoc """
  Runs code formatting for UnifiedUi projects.

  By default this task runs:

  - `mix format`

  ## Options

  - `--check-formatted` - verify files are already formatted
  - `--dry-run` - print files that would be formatted without writing
  - `--dot-formatter` - use an alternate `.formatter.exs` path

  Any additional positional arguments are passed through to `mix format`
  (for example file paths or glob patterns).
  """
  use Mix.Task

  alias UnifiedUi.MixTasks.Runner

  @switches [check_formatted: :boolean, dry_run: :boolean, dot_formatter: :string]

  @impl Mix.Task
  @spec run([String.t()]) :: :ok
  def run(args) do
    run_with(args, Runner)
  end

  @doc false
  @spec run_with([String.t()], module()) :: :ok
  def run_with(args, runner_module) do
    {opts, passthrough, invalid} = OptionParser.parse(args, strict: @switches)

    case invalid do
      [] ->
        :ok

      invalid_opts ->
        raise Mix.Error,
          message:
            "Unsupported options for mix unified_ui.format: #{inspect(invalid_opts)}. " <>
              "Supported options: --check-formatted, --dry-run, --dot-formatter."
    end

    format_args =
      []
      |> maybe_add_flag(opts[:check_formatted], "--check-formatted")
      |> maybe_add_flag(opts[:dry_run], "--dry-run")
      |> maybe_add_option(opts[:dot_formatter], "--dot-formatter")
      |> Kernel.++(passthrough)

    runner_module.run_task("format", format_args)
    :ok
  end

  defp maybe_add_flag(args, true, flag), do: args ++ [flag]
  defp maybe_add_flag(args, _false_or_nil, _flag), do: args

  defp maybe_add_option(args, nil, _option), do: args
  defp maybe_add_option(args, value, option), do: args ++ [option, value]
end
