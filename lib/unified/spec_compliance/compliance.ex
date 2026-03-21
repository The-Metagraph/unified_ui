defmodule Unified.SpecCompliance.Compliance do
  @moduledoc false

  alias Unified.SpecCompliance.{ConformanceManifest, Evidence, Manifest, Plancheck}

  @spec run(String.t(), Keyword.t()) :: map()
  def run(package, opts \\ []) do
    plan_report = Plancheck.run(package, opts)

    if plan_report.status == :fail do
      plan_failure_report(package, plan_report)
    else
      root = Keyword.get(opts, :root, File.cwd!())

      case ConformanceManifest.load(root, package) do
        {:ok, manifest, manifest_findings} ->
          build_compliance_report(package, plan_report, manifest, manifest_findings, root, opts)

        {:error, findings} ->
          manifest_failure_report(package, plan_report, findings)
      end
    end
  end

  defp duplicate_entry_findings(entries_by_id) do
    Enum.flat_map(entries_by_id, fn
      {_requirement_id, [_only]} ->
        []

      {requirement_id, entries} ->
        [
          %{
            code: "duplicate_requirement_entry",
            severity: :error,
            requirement_id: requirement_id,
            message:
              "Conformance manifest includes #{length(entries)} entries for requirement #{inspect(requirement_id)}"
          }
        ]
    end)
  end

  defp missing_entry_findings(applicable_ids, entries_by_id) do
    applicable_ids
    |> Enum.reject(&Map.has_key?(entries_by_id, &1))
    |> Enum.map(fn requirement_id ->
      %{
        code: "missing_requirement_entry",
        severity: :error,
        requirement_id: requirement_id,
        message:
          "Applicable requirement #{inspect(requirement_id)} is missing from the conformance manifest"
      }
    end)
  end

  defp unexpected_entry_findings(entries_by_id, applicable_ids) do
    entries_by_id
    |> Map.keys()
    |> Enum.reject(&MapSet.member?(applicable_ids, &1))
    |> Enum.map(fn requirement_id ->
      %{
        code: "entry_outside_applicability",
        severity: :error,
        requirement_id: requirement_id,
        message:
          "Conformance manifest includes #{inspect(requirement_id)} even though it is not in the applicable requirement set"
      }
    end)
  end

  defp evaluate_entries(_manifest, entries_by_id, applicable_ids, root, opts) do
    entry_map =
      Map.new(entries_by_id, fn {requirement_id, [entry | _]} -> {requirement_id, entry} end)

    applicable_ids
    |> Enum.sort()
    |> Enum.reduce(
      {[], %{verified: 0, waived: 0, planned: 0, implemented: 0, aliases: 0, concrete: 0}, [],
       %{}},
      fn requirement_id, {findings, counts, results, cache} ->
        case Map.get(entry_map, requirement_id) do
          nil ->
            {findings, counts, results, cache}

          %{"inherits_from_requirement_id" => target_id} ->
            concrete = Map.get(entry_map, target_id)

            {entry_findings, bucket, next_cache} =
              evaluate_concrete_entry(requirement_id, concrete, root, opts, cache)

            result = result_entry(requirement_id, "alias", bucket, target_id, entry_findings)

            {
              findings ++ entry_findings,
              counts |> increment_bucket(bucket) |> Map.update!(:aliases, &(&1 + 1)),
              results ++ [result],
              next_cache
            }

          entry ->
            {entry_findings, bucket, next_cache} =
              evaluate_concrete_entry(requirement_id, entry, root, opts, cache)

            result = result_entry(requirement_id, "concrete", bucket, nil, entry_findings)

            {
              findings ++ entry_findings,
              counts |> increment_bucket(bucket) |> Map.update!(:concrete, &(&1 + 1)),
              results ++ [result],
              next_cache
            }
        end
      end
    )
  end

  defp build_compliance_report(package, plan_report, manifest, manifest_findings, root, opts) do
    applicable_ids = plan_report.applicable_requirement_ids
    entries_by_id = ConformanceManifest.entries_by_requirement_id(manifest)

    findings =
      manifest_findings
      |> Kernel.++(duplicate_entry_findings(entries_by_id))
      |> Kernel.++(missing_entry_findings(applicable_ids, entries_by_id))
      |> Kernel.++(unexpected_entry_findings(entries_by_id, applicable_ids))

    {evaluation_findings, summary_counts, results, _cache} =
      evaluate_entries(manifest, entries_by_id, applicable_ids, root, opts)

    findings = Enum.sort_by(findings ++ evaluation_findings, &finding_sort_key/1)
    status = if findings == [], do: :pass, else: :fail
    status_counts = Map.take(summary_counts, [:verified, :waived, :planned, :implemented])

    %{
      kind: :compliance,
      status: status,
      package: package,
      summary: %{
        applicable_requirements: MapSet.size(applicable_ids),
        findings: length(findings),
        aliases: summary_counts.aliases,
        concrete: summary_counts.concrete,
        status_counts: status_counts,
        blocking_requirement_ids: blocking_requirement_ids(findings),
        waived_requirement_ids: requirement_ids_for_status(results, :waived),
        waived_source_requirement_ids: requirement_ids_for_status(results, :waived, "concrete"),
        finding_counts_by_code: finding_counts_by_code(findings),
        ci_enforcement: manifest["ci_enforcement"],
        skipped_commands: Enum.count(findings, &((&1[:code] || &1["code"]) == "command_skipped"))
      },
      findings: findings,
      manifests: %{
        plan: plan_report.manifests.plan,
        conformance: %{
          path: Manifest.relative_path(ConformanceManifest.manifest_path(root, package)),
          version: manifest["version"]
        }
      },
      results: results,
      plan_report: plan_report,
      manifest: manifest
    }
  end

  defp plan_failure_report(package, plan_report) do
    %{
      kind: :compliance,
      status: :fail,
      package: package,
      summary:
        plan_report.summary
        |> Map.put(:phase, :plancheck)
        |> Map.put(:blocking_requirement_ids, blocking_requirement_ids(plan_report.findings))
        |> Map.put(:finding_counts_by_code, finding_counts_by_code(plan_report.findings)),
      findings: plan_report.findings,
      manifests: plan_report[:manifests],
      plan_report: plan_report,
      results: []
    }
  end

  defp manifest_failure_report(package, plan_report, findings) do
    %{
      kind: :compliance,
      status: :fail,
      package: package,
      summary: %{
        applicable_requirements: MapSet.size(plan_report.applicable_requirement_ids),
        findings: length(findings),
        blocking_requirement_ids: blocking_requirement_ids(findings),
        finding_counts_by_code: finding_counts_by_code(findings)
      },
      findings: Enum.sort_by(findings, &finding_sort_key/1),
      manifests: plan_report[:manifests],
      plan_report: plan_report,
      results: []
    }
  end

  defp evaluate_concrete_entry(requirement_id, %{"status" => "planned"}, _root, _opts, cache) do
    {[
       %{
         code: "status_planned",
         severity: :error,
         requirement_id: requirement_id,
         message: "Requirement #{inspect(requirement_id)} is still marked as planned"
       }
     ], :planned, cache}
  end

  defp evaluate_concrete_entry(
         requirement_id,
         %{"status" => "implemented"} = entry,
         root,
         opts,
         cache
       ) do
    {evidence_findings, next_cache} =
      Evidence.run_with_cache(entry["evidence"] || [], root, opts, requirement_id, cache)

    findings =
      evidence_findings ++
        [
          %{
            code: "status_implemented",
            severity: :error,
            requirement_id: requirement_id,
            message: "Requirement #{inspect(requirement_id)} is implemented but not yet verified"
          }
        ]

    {findings, :implemented, next_cache}
  end

  defp evaluate_concrete_entry(
         requirement_id,
         %{"status" => "verified"} = entry,
         root,
         opts,
         cache
       ) do
    {evidence_findings, next_cache} =
      Evidence.run_with_cache(entry["evidence"] || [], root, opts, requirement_id, cache)

    if evidence_findings == [] do
      {[], :verified, next_cache}
    else
      {evidence_findings, :verified, next_cache}
    end
  end

  defp evaluate_concrete_entry(
         requirement_id,
         %{"status" => "waived", "waiver" => waiver},
         _root,
         _opts,
         cache
       ) do
    case waiver_expired?(waiver) do
      true ->
        {[
           %{
             code: "waiver_expired",
             severity: :error,
             requirement_id: requirement_id,
             message: "Waiver for #{inspect(requirement_id)} has expired"
           }
         ], :waived, cache}

      false ->
        {[], :waived, cache}
    end
  end

  defp evaluate_concrete_entry(requirement_id, _entry, _root, _opts, cache) do
    {[
       %{
         code: "invalid_requirement_entry",
         severity: :error,
         requirement_id: requirement_id,
         message: "Requirement entry could not be evaluated"
       }
     ], :planned, cache}
  end

  defp increment_bucket(counts, bucket) do
    Map.update!(counts, bucket, &(&1 + 1))
  end

  defp waiver_expired?(%{"expires_on" => expires_on})
       when is_binary(expires_on) and expires_on != "" do
    case Date.from_iso8601(expires_on) do
      {:ok, date} -> Date.compare(date, Date.utc_today()) == :lt
      _ -> true
    end
  end

  defp waiver_expired?(_waiver), do: false

  defp finding_sort_key(finding) do
    {finding[:requirement_id] || "", finding[:code] || "", finding[:message] || ""}
  end

  defp result_entry(requirement_id, entry_type, bucket, target_id, findings) do
    %{
      requirement_id: requirement_id,
      entry_type: entry_type,
      target_requirement_id: target_id,
      effective_status: bucket,
      compliant?: findings == [] and bucket in [:verified, :waived],
      findings: Enum.map(findings, &Map.take(&1, [:code, :message, :severity]))
    }
  end

  defp blocking_requirement_ids(findings) do
    findings
    |> Enum.map(&(&1[:requirement_id] || &1["requirement_id"]))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp requirement_ids_for_status(results, status) do
    requirement_ids_for_status(results, status, nil)
  end

  defp requirement_ids_for_status(results, status, entry_type) do
    results
    |> Enum.filter(fn result ->
      result.effective_status == status and
        (is_nil(entry_type) or result.entry_type == entry_type)
    end)
    |> Enum.map(& &1.requirement_id)
    |> Enum.sort()
  end

  defp finding_counts_by_code(findings) do
    Enum.reduce(findings, %{}, fn finding, counts ->
      code = finding[:code] || finding["code"] || "finding"
      Map.update(counts, code, 1, &(&1 + 1))
    end)
  end
end
