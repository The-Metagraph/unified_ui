defmodule UnifiedExamples.Shared do
  @moduledoc """
  Package-facing entrypoint for the shared example-suite support library.
  """

  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Documentation
  alias UnifiedExamples.Shared.Maintenance
  alias UnifiedExamples.Shared.AppReadme
  alias UnifiedExamples.Shared.ReleaseReadiness
  alias UnifiedExamples.Shared.Reporting
  alias UnifiedExamples.Shared.SelfContainedBlueprint
  alias UnifiedExamples.Shared.Traceability
  alias UnifiedExamples.Shared.Tooling
  alias UnifiedExamples.Shared.Validation

  @type dependency_app :: :unified_ui | :unified_iur | :live_ui

  @spec dependency_apps() :: [dependency_app()]
  def dependency_apps do
    [:unified_ui, :unified_iur, :live_ui]
  end

  @spec suite_root() :: String.t()
  def suite_root do
    Path.expand("..", shared_root())
  end

  @spec suite_index_path() :: String.t()
  def suite_index_path do
    Path.join(suite_root(), "README.md")
  end

  @spec catalog_manifest_path() :: String.t()
  def catalog_manifest_path do
    Path.join(suite_root(), "catalog.tsv")
  end

  @spec shared_root() :: String.t()
  def shared_root do
    Path.expand("../..", __DIR__)
  end

  @spec app_directories() :: [String.t()]
  def app_directories do
    suite_root()
    |> File.ls!()
    |> Enum.reject(&(&1 == "shared"))
    |> Enum.reject(&String.starts_with?(&1, "."))
    |> Enum.filter(fn entry ->
      suite_root()
      |> Path.join(entry)
      |> File.dir?()
    end)
    |> Enum.sort()
  end

  @spec catalog_entries() :: [Catalog.entry()]
  def catalog_entries do
    Catalog.entries()
  end

  @spec catalog_manifest() :: String.t()
  def catalog_manifest do
    Catalog.tsv()
  end

  @spec preview(String.t() | atom(), :report | :html | :metadata | :inspection) ::
          {:ok, String.t() | map()} | {:error, term()}
  def preview(directory, format \\ :report) do
    Tooling.preview(directory, format)
  end

  @spec run_descriptor(String.t() | atom(), [String.t()]) :: map()
  def run_descriptor(directory, mix_args \\ ["test"]) do
    Tooling.run_descriptor(directory, mix_args)
  end

  @spec launch_descriptor(String.t() | atom(), keyword()) :: map()
  def launch_descriptor(directory, opts \\ []) do
    Tooling.launch_descriptor(directory, opts)
  end

  @spec smoke_launch(String.t() | atom(), keyword()) :: {:ok, map()} | {:error, term()}
  def smoke_launch(directory, opts \\ []) do
    Tooling.smoke_launch(directory, opts)
  end

  @spec review_metadata(String.t() | atom()) :: {:ok, map()} | {:error, term()}
  def review_metadata(directory) do
    Tooling.review_metadata(directory)
  end

  @spec validation_report() :: map()
  def validation_report do
    Validation.report()
  end

  @spec documentation_report() :: map()
  def documentation_report do
    Documentation.report()
  end

  @spec app_readme_report() :: map()
  def app_readme_report do
    AppReadme.report()
  end

  @spec release_readiness_report() :: map()
  def release_readiness_report do
    ReleaseReadiness.report()
  end

  @spec traceability_report() :: map()
  def traceability_report do
    Traceability.report()
  end

  @spec maintenance_report() :: map()
  def maintenance_report do
    Maintenance.report()
  end

  @spec self_contained_blueprint_inventory() :: map()
  def self_contained_blueprint_inventory do
    SelfContainedBlueprint.inventory()
  end

  @spec self_contained_blueprint_baseline() :: map()
  def self_contained_blueprint_baseline do
    SelfContainedBlueprint.current_baseline()
  end

  @spec self_contained_blueprint_target() :: map()
  def self_contained_blueprint_target do
    SelfContainedBlueprint.target_blueprint()
  end

  @spec self_contained_blueprint_policy() :: map()
  def self_contained_blueprint_policy do
    SelfContainedBlueprint.abstraction_boundary_policy()
  end

  @spec suite_report() :: map()
  def suite_report do
    Reporting.suite_report()
  end

  @spec catalog_directories() :: [String.t()]
  def catalog_directories do
    Catalog.directories()
  end

  @spec catalog_by_family() :: %{optional(Catalog.family()) => [Catalog.entry()]}
  def catalog_by_family do
    Catalog.by_family()
  end

  @spec advanced_catalog_directories() :: [String.t()]
  def advanced_catalog_directories do
    Catalog.advanced_directories()
  end

  @spec advanced_app_directories() :: [String.t()]
  def advanced_app_directories do
    advanced_catalog_directories()
    |> Enum.filter(&(&1 in app_directories()))
  end

  @spec missing_advanced_directories() :: [String.t()]
  def missing_advanced_directories do
    advanced_catalog_directories() -- app_directories()
  end

  @spec local_package_paths() :: map()
  def local_package_paths do
    %{
      unified_ui: Path.expand("../../packages/unified-ui", shared_root()),
      unified_iur: Path.expand("../../packages/unified_iur", shared_root()),
      live_ui: Path.expand("../../packages/live_ui", shared_root())
    }
  end
end
