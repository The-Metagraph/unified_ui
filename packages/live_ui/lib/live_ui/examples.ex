defmodule LiveUi.Examples do
  @moduledoc """
  Maintained baseline native and canonical examples for `live_ui`.
  """

  @native_examples [
    LiveUi.Examples.NativeDisplayScreen,
    LiveUi.Examples.NativeFormScreen,
    LiveUi.Examples.NativeNavigationScreen,
    LiveUi.Examples.NativeBoundaryScreen
  ]

  @canonical_examples [
    LiveUi.Examples.CanonicalDisplay,
    LiveUi.Examples.CanonicalForm,
    LiveUi.Examples.CanonicalNavigation,
    LiveUi.Examples.CanonicalBoundaryProfile
  ]

  @mixed_examples [
    LiveUi.Examples.MixedBoundaryTransport
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

  @spec catalog() :: [map()]
  def catalog do
    Enum.map(native_examples(), &example_metadata(&1, :native)) ++
      Enum.map(canonical_examples(), &example_metadata(&1, :canonical)) ++
      Enum.map(mixed_examples(), &example_metadata(&1, :mixed))
  end

  defp example_metadata(module, path) do
    metadata = module.metadata()

    %{
      id: metadata.id,
      title: metadata.title,
      path: path,
      families: metadata.families,
      comparable_to: metadata.comparable_to,
      summary: metadata.summary
    }
  end
end
