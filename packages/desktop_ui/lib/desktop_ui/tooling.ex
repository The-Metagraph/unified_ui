defmodule DesktopUi.Tooling do
  @moduledoc """
  Maintainer-facing tooling surface placeholder for `desktop_ui`.
  """

  @spec documentation_surface() :: [String.t()]
  def documentation_surface do
    [
      "README.md",
      "guides/runtime_backbone.md",
      "guides/native_runtime_and_examples.md",
      "guides/canonical_rendering_and_transport.md",
      "guides/styling_platforms_and_artifacts.md",
      "guides/maintainer_workflows.md"
    ]
  end

  @spec workflows() :: [atom()]
  def workflows do
    [
      :package_checks,
      :example_review,
      :example_preview,
      :reference_inspection,
      :runtime_review,
      :transport_review,
      :style_review,
      :platform_review,
      :package_validation,
      :documentation_review,
      :traceability_review,
      :evolution_policy_review,
      :release_readiness
    ]
  end

  @spec preview_surfaces() :: [module()]
  def preview_surfaces do
    [
      DesktopUi.Reference,
      DesktopUi.Info,
      DesktopUi.Style,
      DesktopUi.Theme,
      DesktopUi.Inspection,
      DesktopUi.Inspect,
      DesktopUi.Validate,
      DesktopUi.Continuity,
      DesktopUi.Examples,
      DesktopUi.Artifacts
    ]
  end

  @spec mix_tasks() :: [String.t()]
  def mix_tasks do
    [
      "mix deps.get",
      "mix compile",
      "mix test",
      "mix desktop_ui.inspect --format catalog",
      "mix desktop_ui.inspect native_styled_review --format diagnostics",
      "mix desktop_ui.validate --strict",
      "mix spec.traceability.generate desktop_ui",
      "mix spec.plancheck desktop_ui"
    ]
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      workflows: workflows(),
      preview_surfaces: preview_surfaces(),
      runtime_validation: DesktopUi.Runtime.validation_state(),
      documentation_validation: DesktopUi.Validate.documentation_surface().status,
      traceability_validation: DesktopUi.Validate.traceability_alignment().status
    }
  end

  @spec preview_example(atom() | String.t()) :: {:ok, map()} | {:error, term()}
  def preview_example(id) do
    DesktopUi.Inspect.preview(id)
  end

  @spec validation_report() :: map()
  def validation_report do
    DesktopUi.Validate.validation_report()
  end

  @spec validation_summary(map()) :: String.t()
  def validation_summary(report) when is_map(report) do
    DesktopUi.Validate.validation_summary(report)
  end
end
