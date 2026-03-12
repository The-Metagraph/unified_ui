defmodule LiveUi.Specs do
  @moduledoc """
  Repo-local entry points for spec governance and compliance checks.
  """

  alias LiveUi.Specs.Checker
  alias LiveUi.Specs.ComplianceReport
  alias LiveUi.Specs.Document
  alias LiveUi.Specs.Parser

  @spec parse_documents(String.t()) :: [Document.t()]
  def parse_documents(glob \\ ".spec/specs/**/*.spec.md") do
    Parser.read_documents(glob)
  end

  @spec check(keyword()) :: ComplianceReport.t()
  def check(opts \\ []) do
    Checker.check_repo(opts)
  end

  @spec write_report(ComplianceReport.t(), String.t()) :: :ok
  def write_report(report, path \\ Checker.default_report_path()) do
    Checker.write_report(report, path)
  end
end
