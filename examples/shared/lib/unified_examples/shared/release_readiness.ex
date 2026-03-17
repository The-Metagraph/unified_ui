defmodule UnifiedExamples.Shared.ReleaseReadiness do
  @moduledoc """
  Release-readiness gates for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.AggregateDemo
  alias UnifiedExamples.Shared
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling

  @type gate :: %{
          passed?: boolean(),
          message: String.t()
        }

  @spec report(
          [{String.t(), {:ok, map()} | {:error, term()}}] | nil,
          {String.t(), {:ok, map()} | {:error, term()}} | nil
        ) :: map()
  def report(metadata_results \\ nil, aggregate_demo_result \\ nil) do
    metadata_results =
      metadata_results ||
        Catalog.directories()
        |> Enum.map(&{&1, Tooling.review_metadata(&1)})

    aggregate_demo_result =
      aggregate_demo_result ||
        {AggregateDemo.directory(), Tooling.review_metadata(AggregateDemo.directory())}

    aggregate_demo_launch_result = {AggregateDemo.directory(), Tooling.smoke_launch(AggregateDemo.directory())}

    metadata = collect_metadata(metadata_results)
    launch_results = Enum.map(Catalog.directories(), &{&1, Tooling.smoke_launch(&1)})
    catalog_gate = catalog_complete_gate()
    primary_subject_gate = primary_subject_gate(metadata)
    shared_template_gate = shared_template_gate(metadata)
    browser_launch_gate = browser_launch_gate(launch_results)
    interaction_story_gate = interaction_story_gate(metadata_results, launch_results)
    aggregate_demo_gate = aggregate_demo_gate(aggregate_demo_result, aggregate_demo_launch_result)

    gates = %{
      catalog_complete: catalog_gate,
      primary_subject_coverage: primary_subject_gate,
      shared_template_continuity: shared_template_gate,
      browser_launch_continuity: browser_launch_gate,
      interaction_story_continuity: interaction_story_gate,
      aggregate_demo_continuity: aggregate_demo_gate
    }

    %{
      checked_directories: Catalog.directories() ++ [AggregateDemo.directory()],
      metadata_load_failures: metadata_load_failures(metadata_results ++ [aggregate_demo_result]),
      launch_failures: launch_failures(launch_results),
      aggregate_demo_launch_failures: launch_failures([aggregate_demo_launch_result]),
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
      "shared_template_continuity?: #{report.gates.shared_template_continuity.passed?}",
      "browser_launch_continuity?: #{report.gates.browser_launch_continuity.passed?}",
      "interaction_story_continuity?: #{report.gates.interaction_story_continuity.passed?}",
      "aggregate_demo_continuity?: #{report.gates.aggregate_demo_continuity.passed?}"
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

  @spec browser_launch_continuity([{String.t(), {:ok, map()} | {:error, term()}}]) :: gate()
  def browser_launch_continuity(results) when is_list(results) do
    browser_launch_gate(results)
  end

  @spec interaction_story_continuity(
          [{String.t(), {:ok, map()} | {:error, term()}}],
          [{String.t(), {:ok, map()} | {:error, term()}}]
        ) :: gate()
  def interaction_story_continuity(metadata_results, launch_results)
      when is_list(metadata_results) and is_list(launch_results) do
    interaction_story_gate(metadata_results, launch_results)
  end

  @spec aggregate_demo_continuity({String.t(), {:ok, map()} | {:error, term()}}) :: gate()
  def aggregate_demo_continuity(result) do
    aggregate_demo_gate(result, nil)
  end

  defp catalog_complete_gate do
    expected = Catalog.directories()
    actual = Shared.app_directories() -- [AggregateDemo.directory()]
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

  defp browser_launch_gate(results) do
    failures =
      Enum.flat_map(results, fn
        {_directory, {:ok, %{status: 200}}} ->
          []

        {directory, {:ok, %{status: status}}} ->
          [%{directory: directory, reason: {:bad_status, status}}]

        {directory, {:error, reason}} ->
          [%{directory: directory, reason: reason}]
      end)

    %{
      passed?: failures == [],
      checked: Enum.map(results, fn {directory, _result} -> directory end),
      failures: failures,
      message:
        "every example app must boot a Phoenix endpoint and serve its LiveView entrypoint through the shared launch contract"
    }
  end

  defp interaction_story_gate(metadata_results, launch_results) do
    metadata_by_directory =
      Map.new(metadata_results, fn
        {directory, {:ok, metadata}} -> {directory, metadata}
        {directory, {:error, _reason}} -> {directory, nil}
      end)

    failures =
      Enum.flat_map(launch_results, fn
        {directory, {:ok, %{body: body}}} ->
          metadata = Map.get(metadata_by_directory, directory)
          interaction_story_failures(directory, metadata, body)

        {directory, {:error, reason}} ->
          [%{directory: directory, reason: {:launch_failed, reason}}]
      end)

    %{
      passed?: failures == [],
      failures: failures,
      message:
        "every example app must expose a meaningful interaction story panel, canonical signal preview, and reviewer-facing interaction copy in the browser"
    }
  end

  defp aggregate_demo_gate({directory, {:ok, metadata}}, smoke_launch_result) do
    signal_lab_contract = Map.get(metadata, :signal_lab_contract, %{})

    failures =
      []
      |> maybe_story_failure(
        directory,
        metadata.theme_id != Template.default_theme_id(),
        :app_theme_mismatch
      )
      |> maybe_story_failure(
        directory,
        metadata.default_theme_id != Template.default_theme_id(),
        :screen_theme_mismatch
      )
      |> maybe_story_failure(
        directory,
        metadata.uses_shared_template != true,
        :style_profile_drift
      )
      |> maybe_story_failure(
        directory,
        Enum.sort(Map.get(metadata, :category_ids, [])) !=
          Enum.sort(AggregateDemo.required_category_ids()),
        :category_registry_mismatch
      )
      |> maybe_story_failure(
        directory,
        Map.get(signal_lab_contract, :valid?) != true,
        :invalid_signal_lab_contract
      )
      |> maybe_story_failure(
        directory,
        Enum.sort(Map.get(signal_lab_contract, :story_ids, [])) !=
          Enum.sort(AggregateDemo.required_signal_lab_story_ids()),
        :signal_lab_story_inventory_mismatch
      )
      |> maybe_story_failure(
        directory,
        Map.get(metadata, :linked_example_directories, []) == [],
        :missing_linked_examples
      )
      |> maybe_story_failure(
        directory,
        smoke_launch_failure?(smoke_launch_result),
        smoke_launch_failure_reason(smoke_launch_result)
      )
      |> maybe_story_failure(
        directory,
        smoke_launch_result_missing?(smoke_launch_result, "Examples Demo Application"),
        :missing_demo_root
      )
      |> maybe_story_failure(
        directory,
        smoke_launch_result_missing?(smoke_launch_result, ~s(data-demo-tablist="true")),
        :missing_tab_shell
      )
      |> maybe_story_failure(
        directory,
        smoke_launch_result_missing?(smoke_launch_result, "Signal Lab"),
        :signal_lab_tab_unreachable
      )
      |> maybe_story_failure(
        directory,
        smoke_launch_result_missing?(smoke_launch_result, ~s(id="demo-category-tab-signal_lab")),
        :signal_lab_tab_id_missing
      )

    %{
      passed?: failures == [],
      checked: [directory],
      smoke_launch: normalize_smoke_launch(smoke_launch_result),
      failures: failures,
      message:
        "the aggregate demo must preserve its tabbed category registry, shared button-example theme continuity, required signal-lab story inventory, and browser-runnable smoke-launch path"
    }
  end

  defp aggregate_demo_gate({directory, {:error, reason}}, _smoke_launch_result) do
    %{
      passed?: false,
      checked: [directory],
      failures: [%{directory: directory, reason: {:review_metadata_failed, reason}}],
      message: "the aggregate demo must be loadable through the shared review-metadata workflow"
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

  defp launch_failures(results) do
    results
    |> Enum.flat_map(fn
      {_directory, {:ok, %{status: 200}}} ->
        []

      {directory, {:ok, %{status: status}}} ->
        [%{directory: directory, reason: {:bad_status, status}}]

      {directory, {:error, reason}} ->
        [%{directory: directory, reason: reason}]
    end)
  end

  defp interaction_story_failures(directory, nil, _body) do
    [%{directory: directory, reason: :missing_review_metadata}]
  end

  defp interaction_story_failures(directory, metadata, body) do
    []
    |> maybe_story_failure(
      directory,
      not String.contains?(body, "Meaningful Interaction Story"),
      :missing_story_panel
    )
    |> maybe_story_failure(
      directory,
      not String.contains?(body, "Canonical Signal Preview"),
      :missing_signal_preview
    )
    |> maybe_story_failure(
      directory,
      metadata.interaction_idle_prompt not in [nil, ""] and
        not String.contains?(body, metadata.interaction_idle_prompt),
      :missing_idle_prompt
    )
    |> maybe_story_failure(
      directory,
      metadata.interaction_trigger_label not in [nil, ""] and
        not String.contains?(body, metadata.interaction_trigger_label),
      :missing_trigger_label
    )
  end

  defp maybe_divergence(divergences, _directory, false, _kind), do: divergences

  defp maybe_divergence(divergences, directory, true, kind) do
    divergences ++ [%{directory: directory, kind: kind}]
  end

  defp maybe_story_failure(failures, _directory, false, _reason), do: failures

  defp maybe_story_failure(failures, directory, true, reason) do
    failures ++ [%{directory: directory, reason: reason}]
  end

  defp smoke_launch_failure?(nil), do: false
  defp smoke_launch_failure?({_directory, {:ok, %{status: 200}}}), do: false
  defp smoke_launch_failure?({_directory, {:ok, %{status: status}}}), do: {:bad_smoke_status, status}
  defp smoke_launch_failure?({_directory, {:error, reason}}), do: {:smoke_launch_failed, reason}

  defp smoke_launch_failure_reason(false), do: false
  defp smoke_launch_failure_reason(reason), do: reason

  defp smoke_launch_result_missing?(nil, _snippet), do: false
  defp smoke_launch_result_missing?({_directory, {:ok, %{body: body}}}, snippet), do: not String.contains?(body, snippet)
  defp smoke_launch_result_missing?({_directory, {:ok, _smoke}}, _snippet), do: true
  defp smoke_launch_result_missing?({_directory, {:error, _reason}}, _snippet), do: false

  defp normalize_smoke_launch(nil), do: nil
  defp normalize_smoke_launch({_directory, {:ok, result}}), do: result
  defp normalize_smoke_launch({_directory, {:error, reason}}), do: %{error: reason}
end
