defmodule Unified.SpecCompliance.PlanManifest do
  @moduledoc false

  alias Unified.SpecCompliance.Manifest

  @scopes ["direct", "inherited", "upstream_constraint"]

  @spec load(String.t(), String.t()) :: {:ok, map(), [map()]} | {:error, [map()]}
  def load(root, package) do
    path = manifest_path(root, package)

    case Manifest.load_json(path) do
      {:ok, data} ->
        findings = validate(data, package, Manifest.relative_path(path))
        {:ok, normalize(data), findings}

      {:error, finding} ->
        {:error, [finding]}
    end
  end

  @spec manifest_path(String.t(), String.t()) :: String.t()
  def manifest_path(root, package) do
    Path.join([root, ".spec", "planning", package, "spec-traceability.json"])
  end

  @spec applicable_requirement_ids(map(), %{optional(String.t()) => map()}) ::
          {MapSet.t(String.t()), [map()]}
  def applicable_requirement_ids(manifest, requirements_by_id) do
    applicability = manifest["applicability"] || %{}
    direct_prefixes = applicability["direct_prefixes"] || []

    direct_matches =
      requirements_by_id
      |> Map.keys()
      |> Enum.filter(fn requirement_id ->
        Enum.any?(direct_prefixes, &String.starts_with?(requirement_id, &1))
      end)

    inherited_ids = applicability["inherited_requirement_ids"] || []
    upstream_ids = applicability["upstream_requirement_ids"] || []
    excluded_ids = applicability["non_applicable_requirement_ids"] || []

    findings =
      inherited_ids
      |> Enum.map(
        &unknown_requirement_finding(&1, "unknown_inherited_requirement_id", requirements_by_id)
      )
      |> Enum.reject(&is_nil/1)
      |> Kernel.++(
        upstream_ids
        |> Enum.map(
          &unknown_requirement_finding(&1, "unknown_upstream_requirement_id", requirements_by_id)
        )
        |> Enum.reject(&is_nil/1)
      )
      |> Kernel.++(
        excluded_ids
        |> Enum.map(
          &unknown_requirement_finding(
            &1,
            "unknown_non_applicable_requirement_id",
            requirements_by_id
          )
        )
        |> Enum.reject(&is_nil/1)
      )

    applicable =
      direct_matches
      |> Kernel.++(Enum.filter(inherited_ids, &Map.has_key?(requirements_by_id, &1)))
      |> Kernel.++(Enum.filter(upstream_ids, &Map.has_key?(requirements_by_id, &1)))
      |> MapSet.new()
      |> then(fn ids -> MapSet.difference(ids, MapSet.new(excluded_ids)) end)

    {applicable, findings}
  end

  @spec mappings_by_requirement_id(map()) :: %{optional(String.t()) => [map()]}
  def mappings_by_requirement_id(manifest) do
    manifest
    |> Map.get("mappings", [])
    |> Enum.group_by(& &1["requirement_id"])
  end

  defp validate(data, package, file) when is_map(data) do
    findings = []
    findings = require_string(findings, data, "package", file, "missing_package")
    findings = require_string(findings, data, "version", file, "missing_version")
    findings = validate_package(findings, data, package, file)
    findings = validate_applicability(findings, data, file)
    findings = validate_mappings(findings, data, file)
    Enum.reverse(findings)
  end

  defp validate(_data, _package, file) do
    [
      %{
        code: "invalid_manifest_shape",
        severity: :error,
        file: file,
        message: "Plan manifest must decode to a JSON object"
      }
    ]
  end

  defp validate_package(findings, data, package, file) do
    case data["package"] do
      ^package ->
        findings

      other when is_binary(other) ->
        [
          %{
            code: "package_mismatch",
            severity: :error,
            file: file,
            message:
              "Plan manifest package #{inspect(other)} does not match requested package #{inspect(package)}"
          }
          | findings
        ]

      _ ->
        findings
    end
  end

  defp validate_applicability(findings, data, file) do
    applicability = data["applicability"]

    if is_map(applicability) do
      findings
      |> require_string_list(applicability, "direct_prefixes", file, "missing_direct_prefixes")
      |> require_array_of_strings(
        applicability,
        "inherited_requirement_ids",
        file,
        "missing_inherited_requirement_ids"
      )
      |> require_array_of_strings(
        applicability,
        "upstream_requirement_ids",
        file,
        "missing_upstream_requirement_ids"
      )
      |> optional_string_list(
        applicability,
        "non_applicable_requirement_ids",
        file,
        "invalid_non_applicable_requirement_ids"
      )
    else
      [
        %{
          code: "missing_applicability",
          severity: :error,
          file: file,
          message: "Plan manifest must include an applicability object"
        }
        | findings
      ]
    end
  end

  defp validate_mappings(findings, data, file) do
    mappings = data["mappings"]

    if is_list(mappings) do
      Enum.reduce(mappings, findings, fn mapping, acc ->
        validate_mapping(acc, mapping, file)
      end)
    else
      [
        %{
          code: "missing_mappings",
          severity: :error,
          file: file,
          message: "Plan manifest must include a mappings array"
        }
        | findings
      ]
    end
  end

  defp validate_mapping(findings, mapping, file) when is_map(mapping) do
    findings
    |> require_string(mapping, "requirement_id", file, "missing_mapping_requirement_id")
    |> require_string(mapping, "scope", file, "missing_mapping_scope")
    |> require_string(mapping, "source_file", file, "missing_mapping_source_file")
    |> require_string(mapping, "ownership_note", file, "missing_mapping_ownership_note")
    |> require_string_list(mapping, "primary_plan_refs", file, "missing_primary_plan_refs")
    |> optional_string_list(mapping, "supporting_plan_refs", file, "invalid_supporting_plan_refs")
    |> validate_scope(mapping, file)
  end

  defp validate_mapping(findings, _mapping, file) do
    [
      %{
        code: "invalid_mapping_shape",
        severity: :error,
        file: file,
        message: "Each plan manifest mapping must be a JSON object"
      }
      | findings
    ]
  end

  defp validate_scope(findings, mapping, file) do
    case mapping["scope"] do
      scope when scope in @scopes ->
        findings

      scope when is_binary(scope) ->
        [
          %{
            code: "invalid_mapping_scope",
            severity: :error,
            file: file,
            requirement_id: mapping["requirement_id"],
            message:
              "Unsupported mapping scope #{inspect(scope)}. Expected one of #{Enum.join(@scopes, ", ")}"
          }
          | findings
        ]

      _ ->
        findings
    end
  end

  defp require_string(findings, map, key, file, code) do
    case map[key] do
      value when is_binary(value) and value != "" -> findings
      _ -> [finding(code, file, "Expected #{key} to be a non-empty string") | findings]
    end
  end

  defp require_string_list(findings, map, key, file, code) do
    case map[key] do
      values when is_list(values) ->
        if values != [] and Enum.all?(values, &is_binary/1) do
          findings
        else
          [finding(code, file, "Expected #{key} to be a non-empty array of strings") | findings]
        end

      _ ->
        [finding(code, file, "Expected #{key} to be a non-empty array of strings") | findings]
    end
  end

  defp optional_string_list(findings, map, key, file, code) do
    case Map.get(map, key) do
      nil ->
        findings

      values when is_list(values) ->
        if Enum.all?(values, &is_binary/1) do
          findings
        else
          [finding(code, file, "Expected #{key} to be an array of strings") | findings]
        end

      _ ->
        [finding(code, file, "Expected #{key} to be an array of strings") | findings]
    end
  end

  defp require_array_of_strings(findings, map, key, file, code) do
    case map[key] do
      values when is_list(values) ->
        if Enum.all?(values, &is_binary/1) do
          findings
        else
          [finding(code, file, "Expected #{key} to be an array of strings") | findings]
        end

      _ ->
        [finding(code, file, "Expected #{key} to be an array of strings") | findings]
    end
  end

  defp finding(code, file, message) do
    %{code: code, severity: :error, file: file, message: message}
  end

  defp unknown_requirement_finding(requirement_id, code, requirements_by_id) do
    if Map.has_key?(requirements_by_id, requirement_id) do
      nil
    else
      %{
        code: code,
        severity: :error,
        requirement_id: requirement_id,
        message: "Unknown requirement id #{inspect(requirement_id)} in applicability section"
      }
    end
  end

  defp normalize(data) do
    data
    |> put_in(
      ["applicability", "non_applicable_requirement_ids"],
      get_in(data, ["applicability", "non_applicable_requirement_ids"]) || []
    )
    |> update_in(["mappings"], fn mappings ->
      Enum.map(mappings || [], fn mapping ->
        Map.put(mapping, "supporting_plan_refs", mapping["supporting_plan_refs"] || [])
      end)
    end)
  end
end
