defmodule SpecComplianceTestSupport do
  @moduledoc false

  @spec tmp_root!(String.t()) :: String.t()
  def tmp_root!(name) do
    root =
      Path.join(System.tmp_dir!(), "unified_spec_compliance_#{name}_#{System.unique_integer([:positive])}")

    File.rm_rf!(root)
    File.mkdir_p!(root)
    root
  end

  @spec write_file!(String.t(), String.t(), String.t()) :: String.t()
  def write_file!(root, relative_path, content) do
    path = Path.join(root, relative_path)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
    path
  end

  @spec write_json!(String.t(), String.t(), map()) :: String.t()
  def write_json!(root, relative_path, data) do
    write_file!(root, relative_path, JSON.encode!(data))
  end

  @spec requirement(String.t(), String.t()) :: map()
  def requirement(id, file \\ ".spec/specs/web_ui/package.spec.md") do
    %{
      "id" => id,
      "subject_id" => id |> String.split(".") |> Enum.take(2) |> Enum.join("."),
      "file" => file
    }
  end

  @spec state([map()]) :: map()
  def state(requirements) do
    %{
      "index" => %{"requirements" => requirements},
      "summary" => %{},
      "findings" => []
    }
  end

  @spec write_minimal_plan_docs!(String.t(), String.t()) :: :ok
  def write_minimal_plan_docs!(root, package) do
    write_file!(
      root,
      ".spec/planning/#{package}/README.md",
      """
      # Test Plan

      [ ] 1 Phase One
      [ ] 1.1 Section
      [ ] 1.1.1 Task
      [ ] 1.1.1.1 Subtask
      [ ] 2.5.1 Task
      """
    )

    write_file!(
      root,
      ".spec/planning/#{package}/phase-01.md",
      """
      # Phase

      [ ] 1 Phase One
      [ ] 1.1 Section
      [ ] 1.1.1 Task
      [ ] 1.1.1.1 Subtask
      [ ] 2.5.1 Task
      """
    )

    :ok
  end

  @spec plan_manifest(String.t(), Keyword.t()) :: map()
  def plan_manifest(package, opts) do
    %{
      "package" => package,
      "version" => "1",
      "applicability" => %{
        "direct_prefixes" => Keyword.get(opts, :direct_prefixes, ["#{package}."]),
        "inherited_requirement_ids" => Keyword.get(opts, :inherited_requirement_ids, []),
        "upstream_requirement_ids" => Keyword.get(opts, :upstream_requirement_ids, []),
        "non_applicable_requirement_ids" => Keyword.get(opts, :non_applicable_requirement_ids, [])
      },
      "mappings" => Keyword.fetch!(opts, :mappings)
    }
  end

  @spec mapping(String.t(), String.t(), String.t(), [String.t()], [String.t()]) :: map()
  def mapping(requirement_id, scope, source_file, primary_refs, supporting_refs \\ []) do
    %{
      "requirement_id" => requirement_id,
      "scope" => scope,
      "source_file" => source_file,
      "primary_plan_refs" => primary_refs,
      "supporting_plan_refs" => supporting_refs,
      "ownership_note" => "test"
    }
  end

  @spec conformance_manifest(String.t(), [map()]) :: map()
  def conformance_manifest(package, requirements) do
    %{
      "package" => package,
      "version" => "1",
      "requirements" => requirements
    }
  end

  @spec concrete_requirement(String.t(), String.t(), [map()]) :: map()
  def concrete_requirement(requirement_id, status, evidence \\ []) do
    %{
      "requirement_id" => requirement_id,
      "status" => status,
      "evidence" => evidence
    }
  end

  @spec alias_requirement(String.t(), String.t()) :: map()
  def alias_requirement(requirement_id, target_id) do
    %{
      "requirement_id" => requirement_id,
      "inherits_from_requirement_id" => target_id
    }
  end
end
