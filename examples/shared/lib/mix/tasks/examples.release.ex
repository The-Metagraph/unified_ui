defmodule Mix.Tasks.Examples.Release do
  use Mix.Task

  @shortdoc "Runs the full example-suite maintainer workflow"

  @moduledoc """
  Runs the full example-suite maintainer workflow.

      mix examples.release
      mix examples.release --format report
      mix examples.release --strict
  """

  alias UnifiedExamples.Shared.Maintenance

  @impl Mix.Task
  def run(args) do
    {opts, _positional, _invalid} =
      OptionParser.parse(args, switches: [format: :string, strict: :boolean])

    format = Keyword.get(opts, :format, "summary")
    strict? = Keyword.get(opts, :strict, false)
    report = Maintenance.report()

    output =
      case format do
        "summary" ->
          Maintenance.summary(report)

        "report" ->
          Kernel.inspect(report, pretty: true, width: 100, limit: :infinity, sort_maps: true)

        other ->
          Mix.raise("unsupported release format #{inspect(other)}")
      end

    Mix.shell().info(output)

    if strict? and not report.valid? do
      Mix.raise("example-suite release workflow failed strict checks")
    end
  end
end
