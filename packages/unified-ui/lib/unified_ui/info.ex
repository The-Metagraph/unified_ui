defmodule UnifiedUi.Info do
  @moduledoc """
  Introspection helpers for modules using `UnifiedUi.Dsl`.

  This module exposes convenient accessors for common DSL data:

  - `widgets/1` - flattened widget entities from the UI tree
  - `layouts/1` - flattened layout entities from the UI tree
  - `styles/1` - named style/theme entities from the styles section
  - `signals/1` - standard signal names available to the DSL

  It also uses `Spark.InfoGenerator` to expose generated option/entity helpers
  for the configured sections.
  """

  use Spark.InfoGenerator,
    extension: UnifiedUi.Dsl.Extension,
    sections: [:signals]

  alias UnifiedUi.Dsl.CompileIndex

  @widget_module_prefixes ["Elixir.UnifiedIUR.Widgets.", "Elixir.UnifiedUi.Widgets."]
  @layout_module_prefixes ["Elixir.UnifiedIUR.Layouts.", "Elixir.UnifiedUi.Layouts."]

  @doc """
  Returns all widget entities from a DSL module or DSL state map.

  Widgets are collected from the flattened UI tree, so nested widgets are
  included.
  """
  @spec widgets(module() | map()) :: [struct()]
  def widgets(dsl_or_extended) do
    dsl_or_extended
    |> compile_index()
    |> Map.get(:flat, [])
    |> Enum.filter(&entity_module_starts_with?(&1, @widget_module_prefixes))
    |> Enum.uniq()
  end

  @doc """
  Returns all layout entities from a DSL module or DSL state map.

  Layouts are collected from the flattened UI tree, so nested layouts are
  included.
  """
  @spec layouts(module() | map()) :: [struct()]
  def layouts(dsl_or_extended) do
    dsl_or_extended
    |> compile_index()
    |> Map.get(:flat, [])
    |> Enum.filter(&entity_module_starts_with?(&1, @layout_module_prefixes))
    |> Enum.uniq()
  end

  @doc """
  Returns style/theme entities from the styles section.
  """
  @spec styles(module() | map()) :: [struct()]
  def styles(dsl_or_extended) do
    Spark.Dsl.Extension.get_entities(dsl_or_extended, :styles)
  end

  @doc """
  Returns the list of supported signal names.

  Signals are currently sourced from `UnifiedUi.Dsl.standard_signals/0`.
  """
  @spec signals(module() | map()) :: [UnifiedUi.Signals.signal_name()]
  def signals(_dsl_or_extended), do: UnifiedUi.Dsl.standard_signals()

  defp compile_index(module) when is_atom(module) do
    module
    |> CompileIndex.runtime_view_state()
    |> CompileIndex.build()
  end

  defp compile_index(%{} = dsl_state), do: CompileIndex.get(dsl_state)
  defp compile_index(_), do: %{flat: []}

  defp entity_module_starts_with?(%{__struct__: module}, prefixes) when is_atom(module) do
    module_string = Atom.to_string(module)
    Enum.any?(prefixes, &String.starts_with?(module_string, &1))
  end

  defp entity_module_starts_with?(_entity, _prefixes), do: false
end
