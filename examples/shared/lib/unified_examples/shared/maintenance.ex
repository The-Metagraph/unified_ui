defmodule UnifiedExamples.Shared.Maintenance do
  @moduledoc """
  Final maintainer workflow for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Documentation
  alias UnifiedExamples.Shared.Reporting
  alias UnifiedExamples.Shared.Traceability
  alias UnifiedExamples.Shared.Validation

  @workflow_steps [
    %{
      name: :discover,
      command: "mix examples.list",
      description:
        "Review the current catalog and confirm the suite entry exists in the shared index."
    },
    %{
      name: :preview,
      command: "mix examples.preview <directory>",
      description: "Preview one target app through the shared template and runtime path."
    },
    %{
      name: :review,
      command: "mix examples.report",
      description: "Inspect the cross-family summary before making or merging changes."
    },
    %{
      name: :validate,
      command: "mix examples.validate --strict",
      description:
        "Check catalog continuity, shared-template continuity, and release-readiness gates."
    },
    %{
      name: :release,
      command: "mix examples.release --strict",
      description:
        "Run the final documented maintainer workflow and fail if the suite is not release-ready."
    }
  ]

  @spec workflow_steps() :: [map()]
  def workflow_steps do
    @workflow_steps
  end

  @spec report() :: map()
  def report do
    documentation = Documentation.report()
    traceability = Traceability.report()
    validation = Validation.report()
    review = Reporting.suite_report()

    %{
      workflow_steps: @workflow_steps,
      documentation: documentation,
      traceability: traceability,
      validation: validation,
      review: review,
      valid?: documentation.valid? and traceability.valid? and validation.valid?
    }
  end

  @spec summary(map()) :: String.t()
  def summary(report) do
    steps =
      Enum.map_join(report.workflow_steps, "\n", fn step ->
        "- #{step.command}: #{step.description}"
      end)

    [
      "Example suite maintainer workflow",
      "valid?: #{report.valid?}",
      "documentation_valid?: #{report.documentation.valid?}",
      "traceability_valid?: #{report.traceability.valid?}",
      "validation_valid?: #{report.validation.valid?}",
      "",
      "Workflow steps:",
      steps
    ]
    |> Enum.join("\n")
  end
end
