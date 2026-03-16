defmodule UnifiedExamples.Shared.ReleaseReadiness do
  @moduledoc """
  Release-readiness gates for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling

  @type gate :: %{
          passed?: boolean(),
          message: String.t()
        }

  @spec report() :: map()
  def report do
    metadata_results =
      Catalog.directories()
      |> Enum.map(&{&1, Tooling.review_metadata(&1)})

    metadata = collect_metadata(metadata_results)
    catalog_gate = catalog_complete_gate()
    primary_subject_gate = primary_subject_gate(metadata)
    shared_template_gate = shared_template_gate(metadata)

    gates = %{
      catalog_complete: catalog_gate,
      primary_subject_coverage: primary_subject_gate,
      shared_template_continuity: shared_template_gate
    }

    %{
      checked_directories: Catalog.directories(),
      metadata_load_failures: metadata_load_failures(metadata_results),
      gates: gates,
      valid?: Enum.all?(Map.values(gates), & &1.passed?)
    }
  end

  @spec summary(map()) :: String.t()
  def summary(report) do
    [
      "Example suite release readiness",
      "valid?: #{report.valid?}",
      "catalog_complete?: #{report.gates.catalog_complete.passed?}",
      "primary_subject_coverage?: #{report.gates.primary_subject_coverage.passed?}",
      "shared_template_continuity?: #{report.gates.shared_template_continuity.passed?}"
    ]
    |> Enum.join("\n")
  end

  @spec primary_subject_coverage([{String.t(), map()}]) :: gate()
  def primary_subject_coverage(metadata) when is_list(metadata) do
    primary_subject_gate(metadata)
  end

  @spec shared_template_continuity([{String.t(), map()}]) :: gate()
  def shared_template_continuity(metadata) when is_list(metadata) do
    shared_template_gate(metadata)
  end

  defp catalog_complete_gate do
    expected = Catalog.directories()
    actual = Shared.app_directories()
    missing = expected -- actual
    unexpected = actual -- expected
    manifest_in_sync? = Shared.catalog_manifest() == File.read!(Shared.catalog_manifest_path())

    %{
      passed?: missing == [] and unexpected == [] and manifest_in_sync?,
      missing_directories: missing,
      unexpected_directories: unexpected,
      manifest_in_sync?: manifest_in_sync?,
      message:
        "catalog completeness requires one app directory per catalog entry and a synchronized manifest"
    }
  end

  defp primary_subject_gate(metadata) do
    expected = Map.new(Catalog.entries(), &{&1.directory, &1.widget})

    mismatches =
      Enum.flat_map(metadata, fn {directory, item} ->
        case Map.fetch(expected, directory) do
          {:ok, widget} when item.primary_subject == widget ->
            []

          {:ok, widget} ->
            [%{directory: directory, expected: widget, actual: item.primary_subject}]

          :error ->
            [%{directory: directory, expected: nil, actual: item.primary_subject}]
        end
      end)

    duplicates =
      metadata
      |> Enum.group_by(fn {_directory, item} -> item.primary_subject end, fn {directory, _item} ->
        directory
      end)
      |> Enum.filter(fn {_subject, directories} -> length(directories) > 1 end)
      |> Map.new()

    actual_subjects =
      metadata |> Enum.map(fn {_directory, item} -> item.primary_subject end) |> MapSet.new()

    expected_subjects = expected |> Map.values() |> MapSet.new()

    %{
      passed?:
        mismatches == [] and duplicates == %{} and
          MapSet.equal?(actual_subjects, expected_subjects),
      mismatches: mismatches,
      duplicate_subjects: duplicates,
      missing_subjects:
        MapSet.to_list(MapSet.difference(expected_subjects, actual_subjects)) |> Enum.sort(),
      message:
        "every example app must own exactly one primary subject and collectively cover the full catalog"
    }
  end

  defp shared_template_gate(metadata) do
    divergent_apps =
      Enum.flat_map(metadata, fn {directory, item} ->
        []
        |> maybe_divergence(directory, item.theme_id != Template.default_theme_id(), :app_theme)
        |> maybe_divergence(
          directory,
          item.default_theme_id != Template.default_theme_id(),
          :screen_theme
        )
        |> maybe_divergence(directory, item.uses_shared_template != true, :style_profile)
      end)

    %{
      passed?: divergent_apps == [],
      divergent_apps: divergent_apps,
      default_theme_id: Template.default_theme_id(),
      default_style_profile: Template.default_style_profile(),
      message: "every example app must reuse the shared template, theme, and style profile"
    }
  end

  defp collect_metadata(results) do
    results
    |> Enum.flat_map(fn
      {directory, {:ok, metadata}} -> [{directory, metadata}]
      {_directory, {:error, _reason}} -> []
    end)
  end

  defp metadata_load_failures(results) do
    results
    |> Enum.flat_map(fn
      {_directory, {:ok, _metadata}} -> []
      {directory, {:error, reason}} -> [%{directory: directory, reason: reason}]
    end)
  end

  defp maybe_divergence(divergences, _directory, false, _kind), do: divergences

  defp maybe_divergence(divergences, directory, true, kind) do
    divergences ++ [%{directory: directory, kind: kind}]
  end
end
