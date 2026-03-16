defmodule UnifiedExamples.MaintenanceTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.Maintenance

  @moduletag timeout: 120_000

  test "maintainer workflow report combines docs, traceability, and validation" do
    report = Maintenance.report()

    assert report.valid?
    assert report.documentation.valid?
    assert report.traceability.valid?
    assert report.validation.valid?

    assert Enum.map(report.workflow_steps, & &1.command) == [
             "mix examples.list",
             "mix examples.preview <directory>",
             "mix examples.report",
             "mix examples.validate --strict",
             "mix examples.release --strict"
           ]
  end

  test "maintainer workflow summary stays actionable and repeatable" do
    summary =
      Maintenance.summary(%{
        valid?: true,
        documentation: %{valid?: true},
        traceability: %{valid?: true},
        validation: %{valid?: true},
        workflow_steps: Maintenance.workflow_steps()
      })

    assert summary =~ "Example suite maintainer workflow"
    assert summary =~ "mix examples.preview <directory>"
    assert summary =~ "mix examples.release --strict"
  end
end
