defmodule Unified.SpecCompliance.ConformanceManifest do
  @moduledoc false

  alias Unified.SpecCompliance.{Evidence, Manifest}

  @statuses ["planned", "implemented", "verified", "waived"]

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
    Path.join([root, ".spec", "conformance", package, "manifest.json"])
  end

  @spec entries_by_requirement_id(map()) :: %{optional(String.t()) => [map()]}
  def entries_by_requirement_id(manifest) do
    manifest
    |> Map.get("requirements", [])
    |> Enum.group_by(& &1["requirement_id"])
  end

  @spec validate_aliases(map(), String.t()) :: [map()]
  def validate_aliases(manifest, file) do
    entries = manifest["requirements"] || []
    by_id = Map.new(entries, fn entry -> {entry["requirement_id"], entry} end)

    Enum.flat_map(entries, fn entry ->
      case entry do
        %{"requirement_id" => requirement_id, "inherits_from_requirement_id" => target_id}
        when is_binary(target_id) ->
          cond do
            target_id == requirement_id ->
              [
                %{
                  code: "alias_self_reference",
                  severity: :error,
                  file: file,
                  requirement_id: requirement_id,
                  message: "Alias entries cannot inherit from themselves"
                }
              ]

            not Map.has_key?(by_id, target_id) ->
              [
                %{
                  code: "alias_target_missing",
                  severity: :error,
                  file: file,
                  requirement_id: requirement_id,
                  message: "Alias target #{inspect(target_id)} is missing"
                }
              ]

            Map.has_key?(by_id[target_id], "inherits_from_requirement_id") ->
              [
                %{
                  code: "alias_target_not_concrete",
                  severity: :error,
                  file: file,
                  requirement_id: requirement_id,
                  message:
                    "Alias target #{inspect(target_id)} must point to a concrete requirement entry"
                }
              ]

            true ->
              []
          end

        _ ->
          []
      end
    end)
  end

  defp validate(data, package, file) when is_map(data) do
    findings = []
    findings = require_string(findings, data, "package", file, "missing_package")
    findings = require_string(findings, data, "version", file, "missing_version")
    findings = validate_package(findings, data, package, file)
    findings = validate_requirements(findings, data, file)
    findings = findings ++ validate_aliases(data, file)
    findings
  end

  defp validate(_data, _package, file) do
    [
      %{
        code: "invalid_manifest_shape",
        severity: :error,
        file: file,
        message: "Conformance manifest must decode to a JSON object"
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
              "Conformance manifest package #{inspect(other)} does not match requested package #{inspect(package)}"
          }
          | findings
        ]

      _ ->
        findings
    end
  end

  defp validate_requirements(findings, data, file) do
    case data["requirements"] do
      requirements when is_list(requirements) ->
        Enum.reduce(requirements, findings, fn requirement, acc ->
          validate_requirement(acc, requirement, file)
        end)

      _ ->
        [
          %{
            code: "missing_requirements",
            severity: :error,
            file: file,
            message: "Conformance manifest must include a requirements array"
          }
          | findings
        ]
    end
  end

  defp validate_requirement(findings, requirement, file) when is_map(requirement) do
    findings
    |> require_string(requirement, "requirement_id", file, "missing_requirement_id")
    |> maybe_validate_requirement_shape(requirement, file)
  end

  defp validate_requirement(findings, _requirement, file) do
    [
      %{
        code: "invalid_requirement_shape",
        severity: :error,
        file: file,
        message: "Each conformance requirement entry must be a JSON object"
      }
      | findings
    ]
  end

  defp maybe_validate_requirement_shape(findings, requirement, file) do
    requirement_id = requirement["requirement_id"]
    alias_target = requirement["inherits_from_requirement_id"]
    status = requirement["status"]

    cond do
      is_binary(alias_target) and not is_nil(status) ->
        [
          %{
            code: "alias_with_status",
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message: "Alias entries cannot define a status"
          }
          | findings
        ]

      is_binary(alias_target) ->
        findings
        |> optional_string(requirement, "notes", file, requirement_id, "invalid_notes")

      true ->
        findings
        |> require_string(requirement, "status", file, "missing_status")
        |> optional_string(requirement, "notes", file, requirement_id, "invalid_notes")
        |> optional_evidence(requirement, file, requirement_id)
        |> optional_waiver(requirement, file, requirement_id)
        |> validate_status(requirement, file)
        |> validate_status_requirements(requirement, file)
    end
  end

  defp validate_status(findings, requirement, file) do
    case requirement["status"] do
      status when status in @statuses ->
        findings

      status when is_binary(status) ->
        [
          %{
            code: "invalid_status",
            severity: :error,
            file: file,
            requirement_id: requirement["requirement_id"],
            message:
              "Unsupported status #{inspect(status)}. Expected one of #{Enum.join(@statuses, ", ")}"
          }
          | findings
        ]

      _ ->
        findings
    end
  end

  defp validate_status_requirements(findings, requirement, file) do
    requirement_id = requirement["requirement_id"]
    status = requirement["status"]
    evidence = requirement["evidence"] || []
    waiver = requirement["waiver"]

    findings =
      if status in ["implemented", "verified"] and evidence == [] do
        [
          %{
            code: "missing_evidence",
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message: "Status #{inspect(status)} requires at least one evidence item"
          }
          | findings
        ]
      else
        findings
      end

    findings =
      if status == "waived" and not is_map(waiver) do
        [
          %{
            code: "missing_waiver",
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message: "Status \"waived\" requires waiver metadata"
          }
          | findings
        ]
      else
        findings
      end

    findings =
      if status != "waived" and is_map(waiver) do
        [
          %{
            code: "unexpected_waiver",
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message: "Only status \"waived\" may include waiver metadata"
          }
          | findings
        ]
      else
        findings
      end

    findings
  end

  defp optional_evidence(findings, requirement, file, requirement_id) do
    case Map.get(requirement, "evidence") do
      nil -> findings
      evidence -> Evidence.validate(evidence, file, requirement_id) ++ findings
    end
  end

  defp optional_waiver(findings, requirement, file, requirement_id) do
    case Map.get(requirement, "waiver") do
      nil ->
        findings

      waiver when is_map(waiver) ->
        findings
        |> require_string(waiver, "reason", file, "missing_waiver_reason", requirement_id)
        |> require_string(
          waiver,
          "approved_by",
          file,
          "missing_waiver_approved_by",
          requirement_id
        )
        |> require_string(
          waiver,
          "approved_on",
          file,
          "missing_waiver_approved_on",
          requirement_id
        )
        |> optional_string(
          waiver,
          "expires_on",
          file,
          requirement_id,
          "invalid_waiver_expires_on"
        )

      _ ->
        [
          %{
            code: "invalid_waiver",
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message: "Waiver metadata must be an object"
          }
          | findings
        ]
    end
  end

  defp require_string(findings, map, key, file, code, requirement_id \\ nil) do
    case map[key] do
      value when is_binary(value) and value != "" ->
        findings

      _ ->
        [
          %{
            code: code,
            severity: :error,
            file: file,
            requirement_id: requirement_id || map["requirement_id"],
            message: "Expected #{key} to be a non-empty string"
          }
          | findings
        ]
    end
  end

  defp optional_string(findings, map, key, file, requirement_id, code) do
    case Map.get(map, key) do
      nil ->
        findings

      value when is_binary(value) ->
        findings

      _ ->
        [
          %{
            code: code,
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message: "Expected #{key} to be a string"
          }
          | findings
        ]
    end
  end

  defp normalize(data) do
    update_in(data, ["requirements"], fn requirements ->
      Enum.map(requirements || [], fn requirement ->
        requirement
        |> Map.update("evidence", [], &(&1 || []))
      end)
    end)
  end
end
