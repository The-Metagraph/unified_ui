defmodule Unified.SpecCompliance.Output do
  @moduledoc false

  @spec render(map(), atom()) :: String.t()
  def render(report, :json) do
    JSON.encode!(json_map(report))
  end

  def render(report, :text) do
    [
      header_line(report),
      summary_block(report),
      requirement_lists_block(report),
      findings_block(report)
    ]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join("\n\n")
    |> Kernel.<>("\n")
  end

  @spec write!(String.t(), String.t(), String.t()) :: String.t()
  def write!(content, path, root) do
    absolute_path = Path.expand(path, root)
    File.mkdir_p!(Path.dirname(absolute_path))
    File.write!(absolute_path, content)
    absolute_path
  end

  defp header_line(report) do
    [
      report.kind || :report,
      "package=#{report.package}",
      "status=#{report.status}"
    ]
    |> Enum.join(" ")
  end

  defp summary_block(report) do
    summary = report.summary || %{}

    lines =
      ["Summary:"]
      |> Kernel.++(summary_lines(summary))
      |> Kernel.++(manifest_lines(report))
      |> Kernel.++(package_lines(report))

    Enum.join(lines, "\n")
  end

  defp summary_lines(summary) do
    summary
    |> Enum.reject(fn {_key, value} -> is_map(value) or is_list(value) end)
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Enum.map(fn {key, value} -> "  #{format_label(key)}: #{format_value(value)}" end)
    |> Kernel.++(nested_summary_lines(summary))
  end

  defp nested_summary_lines(summary) do
    []
    |> append_nested_summary("status_counts", summary[:status_counts] || summary["status_counts"])
    |> append_nested_summary(
      "finding_counts_by_code",
      summary[:finding_counts_by_code] || summary["finding_counts_by_code"]
    )
  end

  defp append_nested_summary(lines, _label, nil), do: lines

  defp append_nested_summary(lines, label, map) when is_map(map) do
    (lines ++
       ["  #{label}:"])
    |> Kernel.++(
      map
      |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
      |> Enum.map(fn {key, value} -> "    #{format_label(key)}: #{format_value(value)}" end)
    )
  end

  defp append_nested_summary(lines, _label, _other), do: lines

  defp manifest_lines(%{manifests: manifests}) when is_map(manifests) do
    manifests
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Enum.flat_map(fn {key, value} ->
      case value do
        %{path: path} ->
          [
            "  manifest #{format_label(key)} path: #{path}"
          ] ++ manifest_metadata_lines(key, value)

        _ ->
          []
      end
    end)
  end

  defp manifest_lines(_report), do: []

  defp manifest_metadata_lines(_key, %{version: version}) when is_binary(version) do
    ["    version: #{version}"]
  end

  defp manifest_metadata_lines(_key, _value), do: []

  defp package_lines(%{packages: packages}) when is_list(packages) do
    if packages == [] do
      []
    else
      [
        "Packages:"
        | Enum.map(packages, fn package ->
            "  [#{String.upcase(to_string(package.status))}] #{package.package} enforcement=#{package.ci_enforcement} findings=#{package.summary.findings}"
          end)
      ]
    end
  end

  defp package_lines(_report), do: []

  defp requirement_lists_block(%{summary: summary}) when is_map(summary) do
    []
    |> append_requirement_list(
      "Blocking Requirements",
      summary[:blocking_requirement_ids] || summary["blocking_requirement_ids"]
    )
    |> append_waived_requirement_list(summary)
    |> case do
      [] -> nil
      blocks -> Enum.join(blocks, "\n\n")
    end
  end

  defp requirement_lists_block(_report), do: nil

  defp append_requirement_list(blocks, _label, ids) when ids in [nil, []], do: blocks

  defp append_requirement_list(blocks, label, ids) when is_list(ids) do
    blocks ++
      [
        [
          "#{label} (#{length(ids)}):",
          Enum.map(ids, &"  - #{&1}")
        ]
        |> List.flatten()
        |> Enum.join("\n")
      ]
  end

  defp append_requirement_list(blocks, _label, _ids), do: blocks

  defp append_waived_requirement_list(blocks, summary) do
    effective_ids = summary[:waived_requirement_ids] || summary["waived_requirement_ids"] || []

    source_ids =
      summary[:waived_source_requirement_ids] || summary["waived_source_requirement_ids"] || []

    cond do
      source_ids != [] ->
        blocks ++
          [
            [
              "Waived Requirements (#{length(source_ids)} source, #{length(effective_ids)} effective):",
              Enum.map(source_ids, &"  - #{&1}")
            ]
            |> List.flatten()
            |> Enum.join("\n")
          ]

      effective_ids != [] ->
        append_requirement_list(blocks, "Waived Requirements", effective_ids)

      true ->
        blocks
    end
  end

  defp findings_block(%{findings: []}), do: "Findings:\n  none"

  defp findings_block(%{findings: findings}) when is_list(findings) do
    [
      "Findings:",
      Enum.map(findings, fn finding -> "  " <> format_finding(finding) end)
    ]
    |> List.flatten()
    |> Enum.join("\n")
  end

  defp findings_block(_report), do: nil

  defp format_finding(finding) do
    code = finding[:code] || finding["code"] || "finding"
    requirement_id = finding[:requirement_id] || finding["requirement_id"] || "-"
    message = finding[:message] || finding["message"] || ""
    "[ERROR] #{requirement_id} #{code} :: #{message}"
  end

  defp json_map(%{kind: :plancheck} = report) do
    %{
      "kind" => "plancheck",
      "package" => report.package,
      "status" => Atom.to_string(report.status),
      "summary" => json_value(report.summary || %{}),
      "manifests" => json_value(report[:manifests] || %{}),
      "findings" => json_value(report.findings || [])
    }
  end

  defp json_map(%{kind: :compliance} = report) do
    payload = %{
      "kind" => "compliance",
      "package" => report.package,
      "status" => Atom.to_string(report.status),
      "summary" => json_value(report.summary || %{}),
      "manifests" => json_value(report[:manifests] || %{}),
      "results" => json_value(report[:results] || []),
      "findings" => json_value(report.findings || [])
    }

    case report[:plan_report] do
      nil ->
        payload

      plan_report ->
        Map.put(
          payload,
          "plancheck",
          %{
            "status" => Atom.to_string(plan_report.status),
            "summary" => json_value(plan_report.summary || %{}),
            "findings" => json_value(plan_report.findings || [])
          }
        )
    end
  end

  defp json_map(%{kind: :ci} = report) do
    %{
      "kind" => "ci",
      "package" => report.package,
      "status" => Atom.to_string(report.status),
      "summary" => json_value(report.summary || %{}),
      "changed_files" => json_value(report[:changed_files] || []),
      "packages" => json_value(report[:packages] || []),
      "findings" => json_value(report.findings || [])
    }
  end

  defp json_map(%{kind: :traceability_generate} = report) do
    %{
      "kind" => "traceability_generate",
      "package" => report.package,
      "status" => Atom.to_string(report.status),
      "summary" => json_value(report.summary || %{}),
      "manifests" => json_value(report[:manifests] || %{}),
      "findings" => json_value(report.findings || [])
    }
  end

  defp json_map(report) when is_map(report) do
    report
    |> Enum.map(fn {key, value} -> {to_string(key), json_value(value)} end)
    |> Map.new()
  end

  defp json_value(value) when is_map(value), do: json_map(value)
  defp json_value(value) when is_list(value), do: Enum.map(value, &json_value/1)
  defp json_value(value) when is_atom(value), do: Atom.to_string(value)
  defp json_value(value), do: value

  defp format_label(key) when is_atom(key), do: format_label(Atom.to_string(key))

  defp format_label(key) when is_binary(key) do
    key
    |> String.replace("_", " ")
  end

  defp format_value(value) when is_list(value), do: inspect(value)
  defp format_value(value), do: to_string(value)
end
