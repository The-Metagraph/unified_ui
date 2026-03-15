defmodule UnifiedUi.Reference do
  @moduledoc """
  Package-facing reference helpers for the authored `UnifiedUi` DSL.
  """

  alias UnifiedUi.Dsl.{Entities, Identity, Placement, SectionRegistry}
  alias UnifiedUi.Examples
  alias UnifiedUi.Theme

  @spec supported_sections() :: [atom()]
  def supported_sections do
    SectionRegistry.section_names()
  end

  @spec dsl_sections() :: %{
          atom() => %{fields: [atom()], purpose: String.t(), top_level?: boolean()}
        }
  def dsl_sections do
    SectionRegistry.sections()
    |> Map.new(fn section ->
      {section.name,
       %{
         fields: Keyword.keys(section.schema),
         purpose: normalize_description(section.describe),
         top_level?: section.top_level?
       }}
    end)
  end

  @spec section_purposes() :: %{atom() => String.t()}
  def section_purposes do
    dsl_sections()
    |> Map.new(fn {name, metadata} -> {name, metadata.purpose} end)
  end

  @spec extension_points() :: %{atom() => [atom()]}
  def extension_points do
    SectionRegistry.extension_points()
  end

  @spec construct_families() :: %{atom() => [atom()]}
  def construct_families do
    Entities.construct_families()
  end

  @spec identity_rules() :: map()
  def identity_rules do
    %{
      required_sections: Identity.required_sections(),
      reserved_ids: Identity.reserved_ids(),
      traceability_fields: Identity.traceability_fields(),
      identifier_fields: Identity.identifier_fields()
    }
  end

  @spec placement_rules() :: map()
  def placement_rules do
    %{
      boundaries: Placement.section_boundaries(),
      rules: Placement.placement_rules()
    }
  end

  @spec example_catalog() :: [map()]
  def example_catalog do
    Examples.catalog()
  end

  @spec theme_catalog(module()) :: [map()]
  def theme_catalog(module) when is_atom(module) do
    module
    |> Theme.themes()
    |> Enum.map(&Theme.summary/1)
  end

  defp normalize_description(description) do
    description
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end
end
