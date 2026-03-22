defmodule Mix.Tasks.TerminalUi.Validate do
  use Mix.Task

  @shortdoc "Runs the maintained terminal_ui validation workflow"

  @moduledoc """
  Runs the maintained `terminal_ui` validation workflow and prints the result.

      mix terminal_ui.validate
      mix terminal_ui.validate --format report
      mix terminal_ui.validate --strict
  """

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _positional, _invalid} =
      OptionParser.parse(args, switches: [format: :string, strict: :boolean])

    format = Keyword.get(opts, :format, "summary")
    strict? = Keyword.get(opts, :strict, false)
    report = TerminalUi.Validate.validation_report()

    output =
      case format do
        "summary" ->
          TerminalUi.Validate.validation_summary(report)

        "report" ->
          Kernel.inspect(report, pretty: true, width: 100, limit: :infinity, sort_maps: true)

        other ->
          Mix.raise("unsupported validate format #{inspect(other)}")
      end

    Mix.shell().info(output)

    if strict? and TerminalUi.Validate.validate(:strict) |> elem(0) == :error do
      Mix.raise("TerminalUi validation failed strict checks")
    end
  end
end
