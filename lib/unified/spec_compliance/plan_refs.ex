defmodule Unified.SpecCompliance.PlanRefs do
  @moduledoc false

  @plan_ref_regex ~r/^\s*\[[ x]\]\s+(\d+(?:\.\d+)*)\b/

  @spec extract(String.t(), String.t()) :: {MapSet.t(String.t()), [String.t()], [map()]}
  def extract(root, package) do
    plan_dir = Path.join([root, ".spec", "planning", package])

    files =
      plan_dir
      |> Path.join("*.md")
      |> Path.wildcard()
      |> Enum.sort()

    findings =
      if files == [] do
        [
          %{
            code: "missing_plan_docs",
            severity: :error,
            file: Path.relative_to(plan_dir, root),
            message: "No planning markdown files found for package #{inspect(package)}"
          }
        ]
      else
        []
      end

    refs =
      files
      |> Enum.flat_map(&extract_refs_from_file/1)
      |> Enum.reject(&is_nil/1)
      |> MapSet.new()

    {refs, Enum.map(files, &Path.relative_to(&1, root)), findings}
  end

  defp extract_refs_from_file(file) do
    file
    |> File.stream!()
    |> Enum.map(&extract_ref/1)
  end

  defp extract_ref(line) do
    case Regex.run(@plan_ref_regex, line) do
      [_, ref] -> ref
      _ -> nil
    end
  end
end
