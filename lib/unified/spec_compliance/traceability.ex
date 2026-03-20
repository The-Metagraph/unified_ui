defmodule Unified.SpecCompliance.Traceability do
  @moduledoc false

  alias Unified.SpecCompliance.{Manifest, PlanManifest}

  @spec markdown_path(String.t(), String.t()) :: String.t()
  def markdown_path(root, package) do
    Path.join([root, ".spec", "planning", package, "spec-traceability.md"])
  end

  @spec generate(String.t(), Keyword.t()) :: map()
  def generate(package, opts \\ []) do
    root = Keyword.get(opts, :root, File.cwd!())

    case PlanManifest.load(root, package) do
      {:ok, manifest, findings} ->
        markdown = render(package, manifest)
        path = markdown_path(root, package)

        if findings != [] do
          %{
            kind: :traceability_generate,
            status: :fail,
            package: package,
            summary: %{findings: length(findings)},
            findings: findings,
            manifests: %{
              plan: %{path: Manifest.relative_path(PlanManifest.manifest_path(root, package))}
            }
          }
        else
          File.mkdir_p!(Path.dirname(path))
          File.write!(path, markdown)

          %{
            kind: :traceability_generate,
            status: :pass,
            package: package,
            summary: %{findings: 0, generated_path: Manifest.relative_path(path)},
            findings: [],
            manifests: %{
              plan: %{
                path: Manifest.relative_path(PlanManifest.manifest_path(root, package)),
                version: manifest["version"]
              },
              traceability_markdown: %{path: Manifest.relative_path(path)}
            }
          }
        end

      {:error, findings} ->
        %{
          kind: :traceability_generate,
          status: :fail,
          package: package,
          summary: %{findings: length(findings)},
          findings: findings
        }
    end
  end

  @spec check_drift(String.t(), String.t(), map()) :: map()
  def check_drift(root, package, manifest) do
    path = markdown_path(root, package)
    generated = render(package, manifest)
    relative_path = Manifest.relative_path(path)

    case File.read(path) do
      {:ok, current} ->
        matches? = normalize_markdown(current) == normalize_markdown(generated)

        %{
          path: relative_path,
          matches?: matches?,
          findings: if(matches?, do: [], else: [drift_finding(package, relative_path)])
        }

      {:error, :enoent} ->
        %{
          path: relative_path,
          matches?: false,
          findings: [
            %{
              code: "missing_traceability_markdown",
              severity: :error,
              file: relative_path,
              message:
                "Missing generated traceability markdown at #{relative_path}. Run `mix spec.traceability.generate #{package}`."
            }
          ]
        }

      {:error, reason} ->
        %{
          path: relative_path,
          matches?: false,
          findings: [
            %{
              code: "traceability_markdown_read_failed",
              severity: :error,
              file: relative_path,
              message:
                "Could not read traceability markdown at #{relative_path}: #{inspect(reason)}"
            }
          ]
        }
    end
  end

  @spec render(String.t(), map()) :: String.t()
  def render(package, manifest) do
    title = package_title(package)
    mappings = manifest["mappings"] || []
    non_applicable = get_in(manifest, ["applicability", "non_applicable_requirement_ids"]) || []

    inherited = Enum.filter(mappings, &(&1["scope"] == "inherited"))
    direct = Enum.filter(mappings, &(&1["scope"] == "direct"))
    upstream = Enum.filter(mappings, &(&1["scope"] == "upstream_constraint"))

    [
      "# #{title} Spec Traceability Matrix",
      "",
      "Generated from the authoritative machine-readable source: [spec-traceability.json](./spec-traceability.json)",
      "",
      "This document maps the `#{package}` implementation plan to the specs referenced by",
      "the planning index. It makes explicit which requirements are delivered directly",
      "by the `#{package}` plan, which ones are inherited from root ecosystem contracts,",
      "and which upstream package specs are treated as input constraints rather than",
      "`#{package}`-owned deliverables.",
      "",
      "## How To Read This Matrix",
      "- `Primary plan coverage` points at the first task that is expected to satisfy",
      "  the requirement intentionally.",
      "- `Supporting coverage` points at later tasks that broaden, validate, document,",
      "  or harden the same contract.",
      "- `Ownership note` distinguishes direct `#{package}` work from inherited or",
      "  upstream constraints.",
      "- Requirement statements remain authoritative in the source spec files; this",
      "  matrix only traces those requirements into plan work.",
      "",
      "## Inherited Root Ecosystem Requirements",
      render_grouped_tables(package, inherited),
      render_non_applicable(package, non_applicable),
      "## Direct `#{package}` Spec Requirements",
      render_grouped_tables(package, direct),
      "## Upstream Canonical Input And Authoring Constraints",
      "These specs are referenced by the planning index because they define the",
      "canonical input surface and authored boundary that `#{package}` must consume or",
      "respect. They are not implemented by `#{package}`, but the plan still needs",
      "deliberate task coverage to preserve compatibility.",
      "",
      render_grouped_tables(package, upstream),
      "## Scenario Alignment Pattern",
      "",
      "The per-spec scenario clauses are covered through the integration-test sections",
      "at the end of every phase:",
      "- Phase 1: `1.5`",
      "- Phase 2: `2.5`",
      "- Phase 3: `3.5`",
      "- Phase 4: `4.5`",
      "- Phase 5: `5.5`",
      "- Phase 6: `6.5`",
      "",
      "This means every requirement in the matrix has both a delivery task and a",
      "phase-closeout verification area in the plan."
    ]
    |> List.flatten()
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  defp render_grouped_tables(_package, []), do: []

  defp render_grouped_tables(package, mappings) do
    mappings
    |> group_preserving_order(fn mapping ->
      source_file_label(package, mapping["source_file"])
    end)
    |> Enum.flat_map(fn {label, rows} ->
      [
        "### `#{label}`",
        "",
        "| Requirement ID | Primary plan coverage | Supporting coverage | Ownership note |",
        "| --- | --- | --- | --- |"
        | Enum.map(rows, &table_row/1)
      ] ++ [""]
    end)
  end

  defp render_non_applicable(_package, []), do: []

  defp render_non_applicable(package, ids) do
    [
      "### Referenced Root Requirements Outside `#{package}` Ownership",
      "",
      "These referenced root requirements are intentionally not mapped to `#{package}`",
      "tasks because they govern other runtime packages:",
      Enum.map(ids, &"- `#{&1}`"),
      ""
    ]
  end

  defp table_row(mapping) do
    supporting =
      case mapping["supporting_plan_refs"] do
        [] -> "-"
        refs -> Enum.map_join(refs, ", ", &"`#{&1}`")
      end

    "| `#{mapping["requirement_id"]}` | #{wrap_refs(mapping["primary_plan_refs"])} | #{supporting} | #{mapping["ownership_note"]} |"
  end

  defp wrap_refs(refs) do
    Enum.map_join(refs || [], ", ", &"`#{&1}`")
  end

  defp drift_finding(package, path) do
    %{
      code: "traceability_markdown_drift",
      severity: :error,
      file: path,
      message:
        "Generated traceability markdown drifted from #{path}. Run `mix spec.traceability.generate #{package}`."
    }
  end

  defp package_title(package) do
    package
    |> String.split("_")
    |> Enum.map_join(&String.capitalize/1)
  end

  defp source_file_label(package, source_file) do
    relative =
      source_file
      |> String.replace_prefix(".spec/specs/", "")

    case String.split(relative, "/", parts: 2) do
      [^package, file] -> file
      [file] -> file
      [parent, file] -> Path.join(parent, file)
    end
  end

  defp group_preserving_order(items, key_fun) do
    Enum.reduce(items, [], fn item, acc ->
      key = key_fun.(item)

      case List.keyfind(acc, key, 0) do
        nil ->
          acc ++ [{key, [item]}]

        {_key, existing} ->
          List.keyreplace(acc, key, 0, {key, existing ++ [item]})
      end
    end)
  end

  defp normalize_markdown(markdown) do
    markdown
    |> String.replace("\r\n", "\n")
    |> String.trim_trailing()
    |> Kernel.<>("\n")
  end
end
