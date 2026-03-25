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
      :host_execution_review,
      :native_build_review,
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
      DesktopUi.Sdl3.App,
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
      "mix desktop_ui.build --target linux --dry-run",
      "mix desktop_ui.build --target linux",
      "mix desktop_ui.build_host --dry-run",
      "mix desktop_ui.build_host",
      "mix desktop_ui.run --format catalog",
      "mix desktop_ui.run native_foundational --format summary",
      "mix desktop_ui.run native_foundational --backend compiled --linger-ms 3000",
      "mix desktop_ui.run native_foundational --format report",
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
      host_execution_validation: DesktopUi.Validate.host_execution_surface().status,
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

  @spec run_catalog() :: map()
  def run_catalog do
    capabilities = DesktopUi.Sdl3.Capabilities.detect()

    %{
      runnable_examples:
        DesktopUi.Examples.catalog()
        |> Enum.filter(&(&1.category in [:native, :canonical]))
        |> Enum.map(& &1.id),
      workflows: workflows(),
      execution: run_backend_summary(capabilities),
      contracts: %{
        build: DesktopUi.Build.contract(),
        host: DesktopUi.Sdl3.PortHost.contract(),
        native_build: DesktopUi.Sdl3.NativeBuild.contract(),
        capabilities: capabilities,
        renderer: DesktopUi.Sdl3.Renderer.contract(),
        visible_runner: DesktopUi.Sdl3.VisibleRunner.contract(),
        text: DesktopUi.Sdl3.Text.contract(),
        images: DesktopUi.Sdl3.Images.contract(),
        events: DesktopUi.Sdl3.Events.contract()
      }
    }
  end

  @spec run_example(atom() | String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def run_example(id, opts \\ []) do
    DesktopUi.Inspect.run_execution(id, opts)
  end

  @spec run_backend_summary(map()) :: map()
  def run_backend_summary(capabilities \\ DesktopUi.Sdl3.Capabilities.detect()) do
    %{
      recommended_backend:
        if(capabilities.build.visible_runner_ready?, do: :compiled_sdl3_host, else: :elixir_host),
      fallback_backend: :elixir_host,
      buildable?: capabilities.build.buildable?,
      visible_runner_ready?: capabilities.build.visible_runner_ready?,
      protocol_launch_ready?: capabilities.build.launch_ready?,
      text: DesktopUi.Sdl3.Text.native_support(capabilities),
      images: DesktopUi.Sdl3.Images.native_support(capabilities),
      target_builds:
        Enum.map(
          DesktopUi.Build.targets(),
          &DesktopUi.Build.build_plan(&1, capabilities: capabilities)
        )
    }
  end
end
