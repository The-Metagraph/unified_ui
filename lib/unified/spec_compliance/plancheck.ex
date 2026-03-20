defmodule Unified.SpecCompliance.Plancheck do
  @moduledoc false

  alias Unified.SpecCompliance.{Manifest, PlanManifest, PlanRefs, State, Traceability}

  @spec run(String.t(), Keyword.t()) :: map()
  def run(package, opts \\ []) do
    root = Keyword.get(opts, :root, File.cwd!())

    with {:ok, state} <- State.load(root, opts),
         {:ok, manifest, manifest_findings} <- PlanManifest.load(root, package) do
      findings = manifest_findings
      {plan_refs, plan_files, plan_findings} = PlanRefs.extract(root, package)
      requirements_by_id = State.requirements_by_id(state)
      traceability = Traceability.check_drift(root, package, manifest)

      {applicable_ids, applicability_findings} =
        PlanManifest.applicable_requirement_ids(manifest, requirements_by_id)

      mappings_by_id = PlanManifest.mappings_by_requirement_id(manifest)

      findings =
        findings
        |> Kernel.++(plan_findings)
        |> Kernel.++(applicability_findings)
        |> Kernel.++(duplicate_mapping_findings(mappings_by_id))
        |> Kernel.++(missing_mapping_findings(applicable_ids, mappings_by_id))
        |> Kernel.++(
          unexpected_mapping_findings(mappings_by_id, applicable_ids, requirements_by_id)
        )
        |> Kernel.++(source_file_findings(mappings_by_id, requirements_by_id))
        |> Kernel.++(plan_ref_findings(mappings_by_id, plan_refs))
        |> Kernel.++(traceability.findings)

      status = if findings == [], do: :pass, else: :fail

      %{
        kind: :plancheck,
        status: status,
        package: package,
        summary: %{
          applicable_requirements: MapSet.size(applicable_ids),
          mappings: map_size(mappings_by_id),
          plan_refs: MapSet.size(plan_refs),
          plan_files: plan_files,
          findings: length(findings),
          blocking_requirement_ids: blocking_requirement_ids(findings),
          finding_counts_by_code: finding_counts_by_code(findings),
          traceability_markdown_in_sync: traceability.matches?
        },
        findings: Enum.sort_by(findings, &finding_sort_key/1),
        manifests: %{
          plan: %{
            path: Manifest.relative_path(PlanManifest.manifest_path(root, package)),
            version: manifest["version"]
          },
          traceability_markdown: %{
            path: traceability.path
          }
        },
        manifest: manifest,
        applicable_requirement_ids: applicable_ids,
        requirements_by_id: requirements_by_id
      }
    else
      {:error, [_finding | _] = findings} ->
        %{
          kind: :plancheck,
          status: :fail,
          package: package,
          summary: %{
            applicable_requirements: 0,
            mappings: 0,
            plan_refs: 0,
            findings: length(findings),
            blocking_requirement_ids: blocking_requirement_ids(findings),
            finding_counts_by_code: finding_counts_by_code(findings)
          },
          findings: Enum.sort_by(findings, &finding_sort_key/1)
        }

      {:error, finding} ->
        %{
          kind: :plancheck,
          status: :fail,
          package: package,
          summary: %{
            applicable_requirements: 0,
            mappings: 0,
            plan_refs: 0,
            findings: 1,
            blocking_requirement_ids: blocking_requirement_ids([finding]),
            finding_counts_by_code: finding_counts_by_code([finding])
          },
          findings: [finding]
        }
    end
  end

  defp duplicate_mapping_findings(mappings_by_id) do
    mappings_by_id
    |> Enum.flat_map(fn
      {_requirement_id, [_only]} ->
        []

      {requirement_id, mappings} ->
        [
          %{
            code: "duplicate_mapping",
            severity: :error,
            requirement_id: requirement_id,
            message:
              "Requirement #{inspect(requirement_id)} appears #{length(mappings)} times in the plan manifest"
          }
        ]
    end)
  end

  defp missing_mapping_findings(applicable_ids, mappings_by_id) do
    applicable_ids
    |> Enum.reject(&Map.has_key?(mappings_by_id, &1))
    |> Enum.map(fn requirement_id ->
      %{
        code: "missing_mapping",
        severity: :error,
        requirement_id: requirement_id,
        message:
          "Applicable requirement #{inspect(requirement_id)} is missing from the plan manifest"
      }
    end)
  end

  defp unexpected_mapping_findings(mappings_by_id, applicable_ids, requirements_by_id) do
    mappings_by_id
    |> Enum.flat_map(fn {requirement_id, _mappings} ->
      cond do
        not Map.has_key?(requirements_by_id, requirement_id) ->
          [
            %{
              code: "unknown_mapping_requirement_id",
              severity: :error,
              requirement_id: requirement_id,
              message:
                "Plan manifest references unknown requirement id #{inspect(requirement_id)}"
            }
          ]

        not MapSet.member?(applicable_ids, requirement_id) ->
          [
            %{
              code: "mapping_outside_applicability",
              severity: :error,
              requirement_id: requirement_id,
              message:
                "Plan manifest maps #{inspect(requirement_id)} even though it is not in the applicable requirement set"
            }
          ]

        true ->
          []
      end
    end)
  end

  defp source_file_findings(mappings_by_id, requirements_by_id) do
    Enum.flat_map(mappings_by_id, fn {requirement_id, mappings} ->
      expected_file =
        requirements_by_id
        |> Map.get(requirement_id, %{})
        |> Map.get("file")

      mapping_source_file_findings(requirement_id, mappings, expected_file)
    end)
  end

  defp plan_ref_findings(mappings_by_id, plan_refs) do
    Enum.flat_map(mappings_by_id, fn {requirement_id, mappings} ->
      Enum.flat_map(mappings, fn mapping ->
        refs = mapping["primary_plan_refs"] ++ mapping["supporting_plan_refs"]
        invalid_refs_for_mapping(requirement_id, refs, plan_refs)
      end)
    end)
  end

  defp mapping_source_file_findings(requirement_id, mappings, expected_file) do
    Enum.flat_map(mappings, fn mapping ->
      source_file_finding(requirement_id, mapping, expected_file)
    end)
  end

  defp source_file_finding(_requirement_id, _mapping, expected_file)
       when not is_binary(expected_file), do: []

  defp source_file_finding(requirement_id, mapping, expected_file) do
    if mapping["source_file"] == expected_file do
      []
    else
      [
        %{
          code: "source_file_mismatch",
          severity: :error,
          requirement_id: requirement_id,
          file: mapping["source_file"],
          message:
            "Plan manifest source file #{inspect(mapping["source_file"])} does not match indexed requirement file #{inspect(expected_file)}"
        }
      ]
    end
  end

  defp invalid_refs_for_mapping(requirement_id, refs, plan_refs) do
    Enum.flat_map(refs, fn ref ->
      invalid_plan_ref_finding(requirement_id, ref, plan_refs)
    end)
  end

  defp invalid_plan_ref_finding(requirement_id, ref, plan_refs) do
    if MapSet.member?(plan_refs, ref) do
      []
    else
      [
        %{
          code: "invalid_plan_ref",
          severity: :error,
          requirement_id: requirement_id,
          message: "Plan manifest references unknown plan checklist id #{inspect(ref)}"
        }
      ]
    end
  end

  defp finding_sort_key(finding) do
    {finding[:requirement_id] || "", finding[:code] || "", finding[:message] || ""}
  end

  defp blocking_requirement_ids(findings) do
    findings
    |> Enum.map(&(&1[:requirement_id] || &1["requirement_id"]))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp finding_counts_by_code(findings) do
    Enum.reduce(findings, %{}, fn finding, counts ->
      code = finding[:code] || finding["code"] || "finding"
      Map.update(counts, code, 1, &(&1 + 1))
    end)
  end
end
