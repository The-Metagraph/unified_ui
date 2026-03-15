defmodule Mix.Tasks.Examples.Report do
  use Mix.Task

  @shortdoc "Prints the standalone example-suite review report"

  @moduledoc """
  Prints the standalone example-suite review report.

      mix examples.report
      mix examples.report --format report
  """

  alias UnifiedExamples.Shared.Reporting

  @impl Mix.Task
  def run(args) do
    {opts, _positional, _invalid} = OptionParser.parse(args, switches: [format: :string])
    format = Keyword.get(opts, :format, "summary")
    report = Reporting.suite_report()

    output =
      case format do
        "summary" ->
          Reporting.summary(report)

        "report" ->
          Kernel.inspect(report, pretty: true, width: 100, limit: :infinity, sort_maps: true)

        other ->
          Mix.raise("unsupported report format #{inspect(other)}")
      end

    Mix.shell().info(output)
  end
end
