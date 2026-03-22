defmodule TerminalUi.Tooling do
  @moduledoc """
  Maintainer workflow surface for `terminal_ui`.
  """

  @spec workflows() :: [atom()]
  def workflows do
    [
      :package_checks,
      :example_review,
      :example_preview,
      :reference_inspection,
      :runtime_review,
      :transport_review,
      :capability_review,
      :package_validation,
      :documentation_review,
      :release_readiness,
      :evolution_policy_review
    ]
  end

  @spec preview_surfaces() :: [module()]
  def preview_surfaces do
    [
      TerminalUi.Reference,
      TerminalUi.Info,
      TerminalUi.Capabilities,
      TerminalUi.Degradation,
      TerminalUi.Inspection,
      TerminalUi.Inspect,
      TerminalUi.Validate,
      TerminalUi.Continuity,
      TerminalUi.Examples
    ]
  end

  @spec mix_tasks() :: [String.t()]
  def mix_tasks do
    [
      "mix deps.get",
      "mix compile",
      "mix test",
      "mix docs",
      "mix terminal_ui.inspect",
      "mix terminal_ui.validate",
      "mix spec.plancheck terminal_ui"
    ]
  end

  @spec documentation_surface() :: [String.t()]
  def documentation_surface do
    [
      "README.md",
      "guides/runtime_backbone.md",
      "guides/native_runtime_and_examples.md",
      "guides/canonical_rendering_and_transport.md",
      "guides/styling_capabilities_and_inspection.md",
      "guides/maintainer_workflows.md"
    ]
  end

  @spec preview_example(atom() | String.t()) :: {:ok, map()} | {:error, term()}
  def preview_example(id) do
    TerminalUi.Inspect.preview(id)
  end

  @spec validation_report() :: map()
  def validation_report do
    TerminalUi.Validate.validation_report()
  end

  @spec validation_summary(map()) :: String.t()
  def validation_summary(report) when is_map(report) do
    TerminalUi.Validate.validation_summary(report)
  end
end
