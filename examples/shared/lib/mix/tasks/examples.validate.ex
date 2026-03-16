defmodule Mix.Tasks.Examples.Validate do
  use Mix.Task

  @shortdoc "Runs the standalone example-suite validation workflow"

  @moduledoc """
  Runs the standalone example-suite validation workflow.

      mix examples.validate
      mix examples.validate --format report
      mix examples.validate --strict
  """

  alias UnifiedExamples.Shared.Validation

  @impl Mix.Task
  def run(args) do
    {opts, _positional, _invalid} =
      OptionParser.parse(args, switches: [format: :string, strict: :boolean])

    format = Keyword.get(opts, :format, "summary")
    strict? = Keyword.get(opts, :strict, false)
    report = Validation.report()

    output =
      case format do
        "summary" ->
          Validation.summary(report)

        "report" ->
          Kernel.inspect(report, pretty: true, width: 100, limit: :infinity, sort_maps: true)

        other ->
          Mix.raise("unsupported validate format #{inspect(other)}")
      end

    Mix.shell().info(output)

    if strict? and not report.valid? do
      Mix.raise("example-suite validation failed strict checks")
    end
  end
end
