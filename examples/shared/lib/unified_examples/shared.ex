defmodule UnifiedExamples.Shared do
  @moduledoc """
  Package-facing entrypoint for the shared example-suite support library.
  """

  alias UnifiedExamples.Shared.Catalog

  @type dependency_app :: :unified_ui | :unified_iur | :live_ui

  @spec dependency_apps() :: [dependency_app()]
  def dependency_apps do
    [:unified_ui, :unified_iur, :live_ui]
  end

  @spec suite_root() :: String.t()
  def suite_root do
    Path.expand("..", shared_root())
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

  @spec catalog_directories() :: [String.t()]
  def catalog_directories do
    Catalog.directories()
  end

  @spec catalog_by_family() :: %{optional(Catalog.family()) => [Catalog.entry()]}
  def catalog_by_family do
    Catalog.by_family()
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
