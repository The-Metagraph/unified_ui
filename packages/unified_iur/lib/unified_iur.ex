defmodule UnifiedIUR do
  @moduledoc """
  Canonical intermediate representation package for the unified ecosystem.

  `UnifiedIUR` is the pure package boundary between authored `unified_ui`
  output and runtime-library renderer entry points.
  """

  @type module_area ::
          :display
          | :core
          | :constructs
          | :interactions
          | :fixtures
          | :validate
          | :normalize
          | :interoperability
          | :extension
          | :reference
          | :tooling

  @module_areas %{
    display: UnifiedIUR.Display,
    core: UnifiedIUR.Core,
    constructs: UnifiedIUR.Constructs,
    interactions: UnifiedIUR.Interactions,
    fixtures: UnifiedIUR.Fixtures,
    validate: UnifiedIUR.Validate,
    normalize: UnifiedIUR.Normalize,
    interoperability: UnifiedIUR.Interoperability,
    extension: UnifiedIUR.Extension,
    reference: UnifiedIUR.Reference,
    tooling: UnifiedIUR.Tooling
  }

  @spec module_areas() :: %{module_area() => module()}
  def module_areas do
    @module_areas
  end

  @spec module_for(module_area()) :: {:ok, module()} | :error
  def module_for(area) do
    Map.fetch(@module_areas, area)
  end
end
