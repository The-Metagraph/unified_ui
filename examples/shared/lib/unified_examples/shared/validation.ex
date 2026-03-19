defmodule UnifiedExamples.Shared.Validation do
  @moduledoc """
  Suite-wide validation for catalog continuity and shared-template reuse.
  """

  alias UnifiedExamples.Shared.AggregateDemo
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
    catalog = catalog_findings(Catalog.directories(), focused_app_directories())
    metadata_results = Enum.map(Catalog.directories(), &{&1, Tooling.review_metadata(&1)})

    aggregate_demo_result =
      {AggregateDemo.directory(), Tooling.review_metadata(AggregateDemo.directory())}

    metadata_issues = Enum.flat_map(metadata_results, &validate_directory_result/1)
    aggregate_demo_issues = validate_directory_result(aggregate_demo_result)
    release = ReleaseReadiness.report(metadata_results, aggregate_demo_result)
    aggregate_demo_present? = AggregateDemo.directory() in Shared.app_directories()

    %{
      catalog:
        catalog
        |> Map.put(:manifest_in_sync?, manifest_in_sync?())
        |> Map.put(:aggregate_demo_present?, aggregate_demo_present?),
      metadata: %{
        checked: length(Catalog.directories()),
        issues: metadata_issues
      },
      aggregate_demo: %{
        checked: 1,
        issues: aggregate_demo_issues
      },
      release: release,
      valid?:
        catalog.missing_directories == [] and
          catalog.unexpected_directories == [] and
          aggregate_demo_present? and
          manifest_in_sync?() and
          metadata_issues == [] and
          aggregate_demo_issues == [] and
          release.valid?
    }
  end

  @spec validate_directory(String.t() | atom()) :: [issue()]
  def validate_directory(directory) do
    directory
    |> Tooling.review_metadata()
    |> then(&validate_directory_result({normalize_directory(directory), &1}))
  end

  @spec validate_aggregate_demo_review_metadata(map()) :: [issue()]
  def validate_aggregate_demo_review_metadata(metadata) when is_map(metadata) do
    required_category_ids = AggregateDemo.required_category_ids()
    required_story_ids = AggregateDemo.required_signal_lab_story_ids()
    category_ids = Map.get(metadata, :category_ids, [])
    signal_lab_contract = Map.get(metadata, :signal_lab_contract, %{})
    style_profile = Map.get(metadata, :style_profile)
    directory = Map.get(metadata, :directory, "unknown")

    []
    |> maybe_issue(
      style_profile != nil and style_profile != Template.default_style_profile(),
      :style_profile_mismatch,
      directory,
      "aggregate demo style profile must stay aligned with the shared button-example baseline"
    )
    |> maybe_issue(
      Map.get(metadata, :theme_id) != Template.default_theme_id(),
      :app_theme_mismatch,
      directory,
      "aggregate demo theme_id must stay aligned with the shared default theme"
    )
    |> maybe_issue(
      Map.get(metadata, :default_theme_id) != Template.default_theme_id(),
      :screen_theme_mismatch,
      directory,
      "aggregate demo default theme must stay aligned with the shared default theme"
    )
    |> maybe_issue(
      Map.get(metadata, :uses_shared_template) != true,
      :shared_template_divergence,
      directory,
      "aggregate demo must continue using the shared template style profile"
    )
    |> maybe_issue(
      Map.get(metadata, :browser_runnable?) != true,
      :not_browser_runnable,
      directory,
      "aggregate demo must remain browser-runnable through Phoenix LiveView"
    )
    |> maybe_issue(
      Map.get(metadata, :dev_server_enabled?) != true,
      :dev_server_disabled,
      directory,
      "aggregate demo must enable its Phoenix endpoint server in dev so mix phx.server works"
    )
    |> maybe_issue(
      Map.get(metadata, :launch_path) != "/",
      :launch_path_mismatch,
      directory,
      "aggregate demo must mount at the shared root path"
    )
    |> maybe_issue(
      not String.contains?(Map.get(metadata, :launch_command, ""), "mix phx.server"),
      :launch_command_mismatch,
      directory,
      "aggregate demo launch metadata must expose a mix phx.server command"
    )
    |> maybe_issue(
      Enum.sort(category_ids) != Enum.sort(required_category_ids),
      :category_registry_mismatch,
      directory,
      "aggregate demo must expose the full required ordered category tab registry"
    )
    |> maybe_issue(
      Map.get(metadata, :category_count) != length(required_category_ids),
      :category_count_mismatch,
      directory,
      "aggregate demo category count must stay aligned with the required category registry"
    )
    |> maybe_issue(
      not is_list(Map.get(metadata, :category_registry)) or Map.get(metadata, :category_registry, []) == [],
      :missing_category_registry,
      directory,
      "aggregate demo must expose category review metadata for each tab"
    )
    |> maybe_issue(
      Enum.any?(Map.get(metadata, :category_registry, []), &(&1.example_count < 1)),
      :missing_category_traceability,
      directory,
      "aggregate demo category metadata must link every tab back to at least one focused example app"
    )
    |> maybe_issue(
      Map.get(metadata, :linked_example_directories, []) == [],
      :missing_linked_examples,
      directory,
      "aggregate demo must expose linked focused example directories for traceability"
    )
    |> maybe_issue(
      Enum.sort(Map.get(metadata, :linked_example_directories, [])) != Catalog.directories(),
      :catalog_traceability_mismatch,
      directory,
      "aggregate demo must keep every focused catalog entry traceable through at least one category tab"
    )
    |> maybe_issue(
      signal_lab_contract == %{} or Map.get(signal_lab_contract, :valid?) != true,
      :invalid_signal_lab_contract,
      directory,
      "aggregate demo signal lab contract must stay valid"
    )
    |> maybe_issue(
      Enum.sort(Map.get(signal_lab_contract, :story_ids, [])) != Enum.sort(required_story_ids),
      :signal_lab_story_inventory_mismatch,
      metadata.directory,
      "aggregate demo signal lab must retain the full required interaction story inventory"
    )
  end

  @spec validate_review_metadata(map()) :: [issue()]
  def validate_review_metadata(%{purpose: :aggregate_demo} = metadata) do
    validate_aggregate_demo_review_metadata(metadata)
  end

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
      metadata.dev_server_enabled? != true,
      :dev_server_disabled,
      metadata.directory,
      "example app must enable its Phoenix endpoint server in dev so mix phx.server works"
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
      metadata.interaction_storytelling in [nil, ""],
      :missing_interaction_storytelling,
      metadata.directory,
      "example app must declare whether its interaction story is source-driven or target-driven"
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
      "aggregate_demo_present?: #{report.catalog.aggregate_demo_present?}",
      "manifest_in_sync?: #{report.catalog.manifest_in_sync?}",
      "metadata_issues: #{length(report.metadata.issues)}",
      "aggregate_demo_issues: #{length(report.aggregate_demo.issues)}",
      "interaction_story_valid?: #{report.release.gates.interaction_story_continuity.passed?}",
      "aggregate_demo_valid?: #{report.release.gates.aggregate_demo_continuity.passed?}",
      "release_valid?: #{report.release.valid?}"
    ]
    |> Enum.join("\n")
  end

  defp manifest_in_sync? do
    File.read!(Shared.catalog_manifest_path()) == Shared.catalog_manifest()
  end

  defp focused_app_directories do
    Shared.app_directories() -- [AggregateDemo.directory()]
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
