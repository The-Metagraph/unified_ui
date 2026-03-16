defmodule UnifiedExamples.Shared.Validation do
  @moduledoc """
  Suite-wide validation for catalog continuity and shared-template reuse.
  """

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling

  @type issue :: %{
          code: atom(),
          directory: String.t() | nil,
          message: String.t()
        }

  @spec report() :: map()
  def report do
    catalog = catalog_findings(Catalog.directories(), Shared.app_directories())
    metadata_issues = Enum.flat_map(Catalog.directories(), &validate_directory/1)

    %{
      catalog: Map.put(catalog, :manifest_in_sync?, manifest_in_sync?()),
      metadata: %{
        checked: length(Catalog.directories()),
        issues: metadata_issues
      },
      valid?:
        catalog.missing_directories == [] and
          catalog.unexpected_directories == [] and
          manifest_in_sync?() and
          metadata_issues == []
    }
  end

  @spec validate_directory(String.t() | atom()) :: [issue()]
  def validate_directory(directory) do
    with {:ok, metadata} <- Tooling.review_metadata(directory) do
      validate_review_metadata(metadata)
    else
      {:error, reason} ->
        [
          %{
            code: :load_failed,
            directory: normalize_directory(directory),
            message: "unable to load review metadata: #{inspect(reason)}"
          }
        ]
    end
  end

  @spec validate_review_metadata(map()) :: [issue()]
  def validate_review_metadata(metadata) when is_map(metadata) do
    []
    |> maybe_issue(
      metadata.theme_id != Template.default_theme_id(),
      :app_theme_mismatch,
      metadata.directory,
      "app metadata theme_id must stay aligned with the shared default theme"
    )
    |> maybe_issue(
      metadata.default_theme_id != Template.default_theme_id(),
      :screen_theme_mismatch,
      metadata.directory,
      "screen default theme must stay aligned with the shared default theme"
    )
    |> maybe_issue(
      metadata.uses_shared_template != true,
      :shared_template_divergence,
      metadata.directory,
      "example app must continue using the shared template style profile"
    )
    |> maybe_issue(
      metadata.shell_kind not in [:box, :form_builder],
      :unsupported_shell_kind,
      metadata.directory,
      "example app must report a supported shared shell kind"
    )
  end

  @spec catalog_findings([String.t()], [String.t()]) :: map()
  def catalog_findings(expected_directories, actual_directories) do
    %{
      expected_directories: Enum.sort(expected_directories),
      actual_directories: Enum.sort(actual_directories),
      missing_directories: Enum.sort(expected_directories -- actual_directories),
      unexpected_directories: Enum.sort(actual_directories -- expected_directories)
    }
  end

  @spec summary(map()) :: String.t()
  def summary(report) do
    [
      "Example suite validation",
      "valid?: #{report.valid?}",
      "catalog_missing: #{Enum.join(report.catalog.missing_directories, ", ")}",
      "catalog_unexpected: #{Enum.join(report.catalog.unexpected_directories, ", ")}",
      "manifest_in_sync?: #{report.catalog.manifest_in_sync?}",
      "metadata_issues: #{length(report.metadata.issues)}"
    ]
    |> Enum.join("\n")
  end

  defp manifest_in_sync? do
    File.read!(Shared.catalog_manifest_path()) == Shared.catalog_manifest()
  end

  defp maybe_issue(issues, false, _code, _directory, _message), do: issues

  defp maybe_issue(issues, true, code, directory, message) do
    issues ++ [%{code: code, directory: normalize_directory(directory), message: message}]
  end

  defp normalize_directory(directory) when is_atom(directory), do: Atom.to_string(directory)
  defp normalize_directory(directory) when is_binary(directory), do: directory
end
