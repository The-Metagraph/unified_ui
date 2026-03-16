defmodule UnifiedExamples.Shared.Traceability do
  @moduledoc """
  Cross-package traceability for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared

  @package_specs %{
    unified_ui: [
      ".spec/specs/unified-ui/package.spec.md",
      ".spec/specs/unified-ui/dsl.spec.md",
      ".spec/specs/unified-ui/compiler.spec.md",
      ".spec/specs/unified-ui/widgets.spec.md",
      ".spec/specs/unified-ui/display_systems.spec.md",
      ".spec/specs/unified-ui/signals.spec.md"
    ],
    unified_iur: [
      ".spec/specs/unified-iur/package.spec.md",
      ".spec/specs/unified-iur/core.spec.md",
      ".spec/specs/unified-iur/constructs.spec.md",
      ".spec/specs/unified-iur/display_systems.spec.md",
      ".spec/specs/unified-iur/interactions.spec.md"
    ],
    live_ui: [
      ".spec/specs/live_ui/package.spec.md",
      ".spec/specs/live_ui/native_widgets.spec.md",
      ".spec/specs/live_ui/iur_renderer.spec.md",
      ".spec/specs/live_ui/runtime.spec.md",
      ".spec/specs/live_ui/transport.spec.md"
    ]
  }

  @general_specs [
    ".spec/specs/architecture.spec.md",
    ".spec/specs/dsl_iur_symbiosis.spec.md",
    ".spec/specs/platform_runtimes.spec.md",
    ".spec/specs/signal_transport.spec.md",
    ".spec/specs/examples/package.spec.md",
    ".spec/specs/examples/dsl_template.spec.md",
    ".spec/specs/examples/catalog.spec.md",
    ".spec/specs/examples/tooling.spec.md"
  ]

  @governance_specs [
    ".spec/specs/governance/contracts/unified_ui_change_contract.spec.md",
    ".spec/specs/governance/contracts/unified_iur_change_contract.spec.md",
    ".spec/specs/governance/contracts/workspace_governance_contract.spec.md"
  ]

  @type package_name :: :unified_ui | :unified_iur | :live_ui

  @spec package_contracts() :: %{optional(package_name()) => map()}
  def package_contracts do
    workspace_root = workspace_root()

    %{
      unified_ui: %{
        package_root: Path.join(workspace_root, "packages/unified-ui"),
        spec_paths: expand_paths(@package_specs.unified_ui)
      },
      unified_iur: %{
        package_root: Path.join(workspace_root, "packages/unified_iur"),
        spec_paths: expand_paths(@package_specs.unified_iur)
      },
      live_ui: %{
        package_root: Path.join(workspace_root, "packages/live_ui"),
        spec_paths: expand_paths(@package_specs.live_ui)
      }
    }
  end

  @spec general_spec_paths() :: [String.t()]
  def general_spec_paths do
    expand_paths(@general_specs)
  end

  @spec governance_paths() :: [String.t()]
  def governance_paths do
    expand_paths(@governance_specs)
  end

  @spec traceability_for(String.t(), module(), module(), [String.t()]) :: map()
  def traceability_for(directory, app_module, screen_module, source_files) do
    contracts = package_contracts()

    %{
      directory: directory,
      flow: [:unified_ui, :unified_iur, :live_ui],
      authored_dsl: %{
        package: :unified_ui,
        package_root: contracts.unified_ui.package_root,
        spec_paths: contracts.unified_ui.spec_paths,
        screen_module: screen_module,
        source_files: source_files,
        compiler_module: UnifiedUi.Compiler
      },
      canonical_iur: %{
        package: :unified_iur,
        package_root: contracts.unified_iur.package_root,
        spec_paths: contracts.unified_iur.spec_paths,
        canonical_module: UnifiedIUR
      },
      runtime_library: %{
        package: :live_ui,
        package_root: contracts.live_ui.package_root,
        spec_paths: contracts.live_ui.spec_paths,
        app_module: app_module,
        runtime_module: LiveUi.Runtime,
        renderer_module: LiveUi.Renderer
      },
      governance_paths: governance_paths(),
      general_spec_paths: general_spec_paths()
    }
  end

  @spec report() :: map()
  def report do
    contracts = package_contracts()

    package_paths =
      Enum.flat_map(contracts, fn {_name, contract} ->
        [contract.package_root | contract.spec_paths]
      end)

    all_paths = package_paths ++ governance_paths() ++ general_spec_paths()

    %{
      packages: contracts,
      governance_paths: governance_paths(),
      general_spec_paths: general_spec_paths(),
      missing_paths: Enum.reject(all_paths, &File.exists?/1),
      valid?: Enum.all?(all_paths, &File.exists?/1)
    }
  end

  defp workspace_root do
    Path.expand("../..", Shared.shared_root())
  end

  defp expand_paths(paths) do
    Enum.map(paths, &Path.join(workspace_root(), &1))
  end
end
