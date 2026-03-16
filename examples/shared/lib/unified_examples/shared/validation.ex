defmodule UnifiedExamples.Shared.Validation do
  @moduledoc """
  Suite-wide validation for catalog continuity and shared-template reuse.
  """

  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.ReleaseReadiness
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
    metadata_results = Enum.map(Catalog.directories(), &{&1, Tooling.review_metadata(&1)})
    metadata_issues = Enum.flat_map(metadata_results, &validate_directory_result/1)
    release = ReleaseReadiness.report(metadata_results)

    %{
      catalog: Map.put(catalog, :manifest_in_sync?, manifest_in_sync?()),
      metadata: %{
        checked: length(Catalog.directories()),
        issues: metadata_issues
      },
      release: release,
      valid?:
        catalog.missing_directories == [] and
          catalog.unexpected_directories == [] and
          manifest_in_sync?() and
          metadata_issues == [] and
          release.valid?
    }
  end

  @spec validate_directory(String.t() | atom()) :: [issue()]
  def validate_directory(directory) do
    directory
    |> Tooling.review_metadata()
    |> then(&validate_directory_result({normalize_directory(directory), &1}))
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
    |> maybe_issue(
      metadata.browser_runnable? != true,
      :not_browser_runnable,
      metadata.directory,
      "example app must expose a browser-runnable Phoenix LiveView baseline"
    )
    |> maybe_issue(
      not is_map(metadata.interaction_demo),
      :missing_interaction_demo,
      metadata.directory,
      "example app must declare a meaningful interaction demonstration contract"
    )
    |> maybe_issue(
      metadata.interaction_family in [nil, ""],
      :missing_interaction_family,
      metadata.directory,
      "example app must declare the primary interaction family reviewers should exercise"
    )
    |> maybe_issue(
      metadata.interaction_outcome in [nil, ""],
      :missing_interaction_outcome,
      metadata.directory,
      "example app must declare the reviewer-visible interaction outcome"
    )
    |> maybe_issue(
      metadata.interaction_idle_prompt in [nil, ""],
      :missing_interaction_prompt,
      metadata.directory,
      "example app must explain what interaction reviewers should try before any signal is captured"
    )
    |> maybe_issue(
      metadata.launch_path != "/",
      :launch_path_mismatch,
      metadata.directory,
      "example app must mount its browser entrypoint at the shared root path"
    )
    |> maybe_issue(
      not String.contains?(metadata.launch_command || "", "mix phx.server"),
      :launch_command_mismatch,
      metadata.directory,
      "example app launch metadata must expose a mix phx.server command"
    )
    |> maybe_issue(
      not String.contains?(metadata.launch_url || "", metadata.launch_path || "/"),
      :launch_url_mismatch,
      metadata.directory,
      "example app launch metadata must expose a URL aligned with the mount path"
    )
    |> maybe_missing_module(
      metadata.application_module,
      :missing_application_module,
      metadata.directory,
      "example app must expose an application module for the Phoenix baseline"
    )
    |> maybe_missing_module(
      metadata.endpoint_module,
      :missing_endpoint_module,
      metadata.directory,
      "example app must expose an endpoint module for the Phoenix baseline"
    )
    |> maybe_missing_module(
      metadata.router_module,
      :missing_router_module,
      metadata.directory,
      "example app must expose a router module for the Phoenix baseline"
    )
    |> maybe_missing_module(
      metadata.live_module,
      :missing_live_module,
      metadata.directory,
      "example app must expose a LiveView module for the Phoenix baseline"
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
      "metadata_issues: #{length(report.metadata.issues)}",
      "release_valid?: #{report.release.valid?}"
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

  defp maybe_missing_module(issues, module, code, directory, message) do
    maybe_issue(issues, not Code.ensure_loaded?(module), code, directory, message)
  end

  defp validate_directory_result({_directory, {:ok, metadata}}) do
    validate_review_metadata(metadata)
  end

  defp validate_directory_result({directory, {:error, reason}}) do
    [
      %{
        code: :load_failed,
        directory: normalize_directory(directory),
        message: "unable to load review metadata: #{inspect(reason)}"
      }
    ]
  end

  defp normalize_directory(directory) when is_atom(directory), do: Atom.to_string(directory)
  defp normalize_directory(directory) when is_binary(directory), do: directory
end
