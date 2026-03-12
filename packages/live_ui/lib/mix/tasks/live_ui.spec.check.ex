defmodule Mix.Tasks.LiveUi.Spec.Check do
  @moduledoc """
  Runs the repo-local governance/compliance overlay and writes a derived JSON report.
  """

  use Mix.Task

  alias LiveUi.Specs
  alias LiveUi.Specs.Checker

  @shortdoc "Validate the local governance overlay and emit a compliance report"

  @impl true
  def run(args) do
    {opts, _argv, _invalid} =
      OptionParser.parse(args, strict: [report: :string, strict: :boolean])

    report_path = Keyword.get(opts, :report, Checker.default_report_path())
    strict? = Keyword.get(opts, :strict, false)

    report = Specs.check(root: File.cwd!())
    :ok = Specs.write_report(report, report_path)

    summary = Checker.summary(report)

    Mix.shell().info("Spec compliance report written to #{report_path}")
    Mix.shell().info("pass=#{summary.pass} warn=#{summary.warn} fail=#{summary.fail}")

    cond do
      summary.fail > 0 ->
        Mix.raise("spec compliance failed")

      strict? and summary.warn > 0 ->
        Mix.raise("spec compliance produced warnings in strict mode")

      true ->
        :ok
    end
  end
end
