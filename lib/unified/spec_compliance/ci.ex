defmodule Unified.SpecCompliance.CI do
  @moduledoc false

  alias Unified.SpecCompliance.{Compliance, PlanManifest}

  @framework_path_prefixes [
    "lib/unified/spec_compliance/",
    "lib/mix/tasks/spec.plancheck.ex",
    "lib/mix/tasks/spec.compliance.ex",
    "lib/mix/tasks/spec.compliance.ci.ex",
    "lib/mix/tasks/spec.traceability.generate.ex",
    ".spec/conformance/README.md",
    ".spec/specs/conformance_layer.spec.md"
  ]

  @spec run(Keyword.t()) :: map()
  def run(opts \\ []) do
    root = Keyword.get(opts, :root, File.cwd!())
    packages = discover_packages(root)
    changed_files = changed_files(root, opts)
    affected_packages = affected_packages(root, packages, changed_files)
    package_reports = Enum.map(affected_packages, &package_report(&1, opts))
    required_failures = failure_packages(package_reports, "required")
    warn_failures = failure_packages(package_reports, "warn")
    findings = build_findings(required_failures, warn_failures)

    %{
      kind: :ci,
      status: ci_status(required_failures, warn_failures),
      package: "package-scoped",
      summary: %{
        changed_files: length(changed_files),
        affected_packages: length(affected_packages),
        required_failures: length(required_failures),
        warn_failures: length(warn_failures),
        findings: length(findings)
      },
      findings: findings,
      packages: package_reports,
      changed_files: changed_files
    }
  end

  @spec affected_packages(String.t(), [String.t()], [String.t()]) :: [String.t()]
  def affected_packages(root, packages, changed_files) do
    if changed_files == [] or framework_changed?(changed_files) do
      packages
    else
      Enum.filter(packages, &package_affected?(root, &1, changed_files))
    end
  end

  defp discover_packages(root) do
    root
    |> Path.join(".spec/conformance/*/manifest.json")
    |> Path.wildcard()
    |> Enum.map(fn path ->
      path |> Path.dirname() |> Path.basename()
    end)
    |> Enum.sort()
  end

  defp package_relevant_paths(root, package) do
    source_files =
      case PlanManifest.load(root, package) do
        {:ok, manifest, _findings} ->
          manifest
          |> Map.get("mappings", [])
          |> Enum.map(& &1["source_file"])
          |> Enum.uniq()

        _ ->
          []
      end

    package_path_variants = package_path_variants(package)

    [
      ".spec/conformance/#{package}/",
      ".spec/planning/#{package}/",
      source_files
      | Enum.flat_map(package_path_variants, fn variant ->
          [
            ".spec/specs/#{variant}/",
            "packages/#{variant}/"
          ]
        end)
    ]
    |> List.flatten()
    |> Enum.uniq()
  end

  defp changed_files(root, opts) do
    changed_files = Keyword.get_values(opts, :changed_file)

    cond do
      changed_files != [] ->
        Enum.sort(changed_files)

      base = Keyword.get(opts, :base) ->
        git_changed_files(root, base, Keyword.get(opts, :head, "HEAD"))

      true ->
        []
    end
  end

  defp git_changed_files(root, base, head) do
    {output, 0} =
      System.cmd("git", ["diff", "--name-only", "#{base}...#{head}"],
        cd: root,
        stderr_to_stdout: true
      )

    output
    |> String.split("\n", trim: true)
    |> Enum.sort()
  rescue
    error ->
      reraise Mix.Error,
              [
                message:
                  "Could not determine changed files for CI compliance: #{Exception.message(error)}"
              ],
              __STACKTRACE__
  end

  defp framework_changed?(changed_files) do
    Enum.any?(changed_files, fn file ->
      Enum.any?(@framework_path_prefixes, fn prefix ->
        String.starts_with?(file, prefix) or file == prefix
      end)
    end)
  end

  defp package_findings(packages, code, severity) do
    Enum.map(packages, fn package ->
      %{
        code: code,
        severity: severity,
        requirement_id: package,
        message: "Compliance CI reported #{severity} for package #{inspect(package)}"
      }
    end)
  end

  defp package_report(package, opts) do
    report = Compliance.run(package, opts)
    ci_enforcement = get_in(report, [:manifest, "ci_enforcement"]) || "warn"

    %{
      package: package,
      ci_enforcement: ci_enforcement,
      status: package_status(report.status, ci_enforcement),
      summary: report.summary,
      report: report
    }
  end

  defp package_status(:pass, _ci_enforcement), do: :pass
  defp package_status(:fail, "warn"), do: :warn
  defp package_status(:fail, _ci_enforcement), do: :fail

  defp failure_packages(package_reports, enforcement) do
    package_reports
    |> Enum.filter(&(&1.ci_enforcement == enforcement and &1.report.status == :fail))
    |> Enum.map(& &1.package)
  end

  defp build_findings(required_failures, warn_failures) do
    []
    |> Kernel.++(package_findings(required_failures, "required_package_failure", :error))
    |> Kernel.++(package_findings(warn_failures, "warn_package_failure", :warning))
  end

  defp ci_status(required_failures, warn_failures) do
    cond do
      required_failures != [] -> :fail
      warn_failures != [] -> :warn
      true -> :pass
    end
  end

  defp package_affected?(root, package, changed_files) do
    relevant_paths = package_relevant_paths(root, package)
    Enum.any?(changed_files, &matches_any_path?(&1, relevant_paths))
  end

  defp matches_any_path?(file, relevant_paths) do
    Enum.any?(relevant_paths, fn path ->
      String.starts_with?(file, path) or file == path
    end)
  end

  defp package_path_variants(package) do
    [package, String.replace(package, "_", "-")]
    |> Enum.uniq()
  end
end
