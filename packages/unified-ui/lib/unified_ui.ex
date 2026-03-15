defmodule UnifiedUi do
  @moduledoc """
  Canonical authored DSL and compiler package for the unified ecosystem.

  `UnifiedUi` defines the authored module boundary used to describe widgets,
  display systems, theming, and canonical interaction intent before lowering
  them into `UnifiedIUR`.
  """

  @type module_area :: :dsl | :compiler | :signals | :reference | :tooling

  @module_areas %{
    dsl: UnifiedUi.Dsl,
    compiler: UnifiedUi.Compiler,
    signals: UnifiedUi.Signals,
    reference: UnifiedUi.Reference,
    tooling: UnifiedUi.Tooling
  }

  @spec package_identity() :: map()
  def package_identity do
    %{
      app: :unified_ui,
      namespace: __MODULE__,
      package_path: "packages/unified-ui",
      pure_library?: true
    }
  end

  @spec module_areas() :: %{module_area() => module()}
  def module_areas do
    @module_areas
  end

  @spec module_for(module_area()) :: {:ok, module()} | :error
  def module_for(area) do
    Map.fetch(@module_areas, area)
  end

  @spec required_runtime_services() :: []
  def required_runtime_services do
    []
  end
end
