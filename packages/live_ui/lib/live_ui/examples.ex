defmodule LiveUi.Examples do
  @moduledoc """
  Maintained baseline native and canonical examples for `live_ui`.
  """

  @type example_path :: :native | :canonical | :mixed

  @native_examples [
    LiveUi.Examples.NativeDisplayScreen,
    LiveUi.Examples.NativeFormScreen,
    LiveUi.Examples.NativeNavigationScreen,
    LiveUi.Examples.NativeBoundaryScreen,
    LiveUi.Examples.NativeStyledProfileScreen,
    LiveUi.Examples.NativeStyledOperationsScreen
  ]

  @canonical_examples [
    LiveUi.Examples.CanonicalDisplay,
    LiveUi.Examples.CanonicalForm,
    LiveUi.Examples.CanonicalNavigation,
    LiveUi.Examples.CanonicalBoundaryProfile,
    LiveUi.Examples.CanonicalStyledProfile,
    LiveUi.Examples.CanonicalStyledOperations
  ]

  @mixed_examples [
    LiveUi.Examples.MixedBoundaryTransport,
    LiveUi.Examples.StyledContinuityComparison
  ]

  @spec native_examples() :: [module()]
  def native_examples do
    @native_examples
  end

  @spec canonical_examples() :: [module()]
  def canonical_examples do
    @canonical_examples
  end

  @spec mixed_examples() :: [module()]
  def mixed_examples do
    @mixed_examples
  end

  @spec grouped_catalog() :: %{native: [map()], canonical: [map()], mixed: [map()]}
  def grouped_catalog do
    %{
      native: Enum.map(native_examples(), &example_metadata(&1, :native)),
      canonical: Enum.map(canonical_examples(), &example_metadata(&1, :canonical)),
      mixed: Enum.map(mixed_examples(), &example_metadata(&1, :mixed))
    }
  end

  @spec catalog() :: [map()]
  def catalog do
    grouped_catalog().native ++ grouped_catalog().canonical ++ grouped_catalog().mixed
  end

  @spec find(atom() | String.t()) :: {:ok, map()} | :error
  def find(id) when is_atom(id) or is_binary(id) do
    wanted = to_string(id)

    catalog()
    |> Enum.find(&(to_string(&1.id) == wanted))
    |> case do
      nil -> :error
      example -> {:ok, example}
    end
  end

  defp example_metadata(module, path) do
    metadata = module.metadata()
    preview_id = "#{path}:#{metadata.id}"

    %{
      id: metadata.id,
      title: metadata.title,
      module: module,
      path: path,
      families: metadata.families,
      comparable_to: metadata.comparable_to,
      summary: metadata.summary,
      preview_id: preview_id,
      review_artifact: "live_ui/#{path}/#{metadata.id}",
      coverage: coverage_metadata(path, metadata),
      runtime_obligations: runtime_obligations(path, metadata)
    }
  end

  defp coverage_metadata(path, metadata) do
    %{
      native?: path in [:native, :mixed],
      canonical?: path in [:canonical, :mixed],
      transport?: :transport in metadata.families or :signal in metadata.families,
      continuity?: not is_nil(metadata.comparable_to),
      advanced?:
        Enum.any?(metadata.families, &(&1 in [:overlay, :operational, :comparison, :styling]))
    }
  end

  defp runtime_obligations(path, metadata) do
    %{
      server_authoritative?: true,
      preview_mode: path,
      canonical_boundary?: :transport in metadata.families or :signal in metadata.families,
      comparable_to: metadata.comparable_to
    }
  end
end
