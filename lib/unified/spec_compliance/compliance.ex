defmodule Unified.SpecCompliance.Compliance do
  @moduledoc false

  alias Unified.SpecCompliance.{ConformanceManifest, Evidence, Plancheck}

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
    |> Enum.reduce({[], %{verified: 0, waived: 0, planned: 0, implemented: 0}}, fn requirement_id,
                                                                                   {findings,
                                                                                    counts} ->
      case Map.get(entry_map, requirement_id) do
        nil ->
          {findings, counts}

        %{"inherits_from_requirement_id" => target_id} ->
          concrete = Map.get(entry_map, target_id)

          {entry_findings, bucket} =
            evaluate_concrete_entry(requirement_id, concrete, root, opts, aliased?: true)

          {findings ++ entry_findings, increment_bucket(counts, bucket)}

        entry ->
          {entry_findings, bucket} =
            evaluate_concrete_entry(requirement_id, entry, root, opts, aliased?: false)

          {findings ++ entry_findings, increment_bucket(counts, bucket)}
      end
    end)
  end

  defp build_compliance_report(package, plan_report, manifest, manifest_findings, root, opts) do
    applicable_ids = plan_report.applicable_requirement_ids
    entries_by_id = ConformanceManifest.entries_by_requirement_id(manifest)

    findings =
      manifest_findings
      |> Kernel.++(duplicate_entry_findings(entries_by_id))
      |> Kernel.++(missing_entry_findings(applicable_ids, entries_by_id))
      |> Kernel.++(unexpected_entry_findings(entries_by_id, applicable_ids))

    {evaluation_findings, summary_counts} =
      evaluate_entries(manifest, entries_by_id, applicable_ids, root, opts)

    findings = Enum.sort_by(findings ++ evaluation_findings, &finding_sort_key/1)
    status = if findings == [], do: :pass, else: :fail

    %{
      status: status,
      package: package,
      summary:
        Map.merge(summary_counts, %{
          applicable_requirements: MapSet.size(applicable_ids),
          findings: length(findings)
        }),
      findings: findings,
      plan_report: plan_report,
      manifest: manifest
    }
  end

  defp plan_failure_report(package, plan_report) do
    %{
      status: :fail,
      package: package,
      summary: Map.put(plan_report.summary, :phase, :plancheck),
      findings: plan_report.findings,
      plan_report: plan_report
    }
  end

  defp manifest_failure_report(package, plan_report, findings) do
    %{
      status: :fail,
      package: package,
      summary: %{
        applicable_requirements: MapSet.size(plan_report.applicable_requirement_ids),
        findings: length(findings)
      },
      findings: Enum.sort_by(findings, &finding_sort_key/1),
      plan_report: plan_report
    }
  end

  defp evaluate_concrete_entry(requirement_id, %{"status" => "planned"}, _root, _opts, _options) do
    {[
       %{
         code: "status_planned",
         severity: :error,
         requirement_id: requirement_id,
         message: "Requirement #{inspect(requirement_id)} is still marked as planned"
       }
     ], :planned}
  end

  defp evaluate_concrete_entry(
         requirement_id,
         %{"status" => "implemented"} = entry,
         root,
         opts,
         _options
       ) do
    evidence_findings = Evidence.run(entry["evidence"] || [], root, opts, requirement_id)

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

    {findings, :implemented}
  end

  defp evaluate_concrete_entry(
         requirement_id,
         %{"status" => "verified"} = entry,
         root,
         opts,
         _options
       ) do
    evidence_findings = Evidence.run(entry["evidence"] || [], root, opts, requirement_id)

    if evidence_findings == [] do
      {[], :verified}
    else
      {evidence_findings, :verified}
    end
  end

  defp evaluate_concrete_entry(
         requirement_id,
         %{"status" => "waived", "waiver" => waiver},
         _root,
         _opts,
         _options
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
         ], :waived}

      false ->
        {[], :waived}
    end
  end

  defp evaluate_concrete_entry(requirement_id, _entry, _root, _opts, _options) do
    {[
       %{
         code: "invalid_requirement_entry",
         severity: :error,
         requirement_id: requirement_id,
         message: "Requirement entry could not be evaluated"
       }
     ], :planned}
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
end
