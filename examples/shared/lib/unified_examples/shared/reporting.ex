defmodule UnifiedExamples.Shared.Reporting do
  @moduledoc """
  Cross-family review reporting for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Validation

  @spec suite_report() :: map()
  def suite_report do
    validation = Validation.report()
    families = Catalog.by_family()

    %{
      index: %{
        readme_path: Shared.suite_index_path(),
        manifest_path: Shared.catalog_manifest_path()
      },
      catalog: %{
        total: length(Catalog.entries()),
        by_family:
          Map.new(families, fn {family, entries} ->
            {family, Enum.map(entries, & &1.directory)}
          end),
        family_counts:
          Map.new(families, fn {family, entries} ->
            {family, length(entries)}
          end)
      },
      template: %{
        default_theme_id: Template.default_theme_id(),
        aligned_apps:
          Enum.sort(
            Catalog.directories() --
              Enum.map(validation.metadata.issues, & &1.directory)
          ),
        divergent_apps:
          validation.metadata.issues
          |> Enum.map(& &1.directory)
          |> Enum.reject(&is_nil/1)
          |> Enum.uniq()
          |> Enum.sort()
      },
      validation: validation
    }
  end

  @spec summary(map()) :: String.t()
  def summary(report) do
    family_counts =
      report.catalog.family_counts
      |> Enum.map(fn {family, count} -> "#{family}=#{count}" end)
      |> Enum.sort()
      |> Enum.join(", ")

    [
      "Example suite review report",
      "catalog_total: #{report.catalog.total}",
      "family_counts: #{family_counts}",
      "default_theme_id: #{report.template.default_theme_id}",
      "aligned_apps: #{length(report.template.aligned_apps)}",
      "divergent_apps: #{Enum.join(report.template.divergent_apps, ", ")}",
      "validation_valid?: #{report.validation.valid?}"
    ]
    |> Enum.join("\n")
  end
end
