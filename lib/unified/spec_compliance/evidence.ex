defmodule Unified.SpecCompliance.Evidence do
  @moduledoc false

  @valid_kinds ["path_exists", "path_absent", "path_glob_nonempty", "command"]

  @spec validate([map()], String.t(), String.t()) :: [map()]
  def validate(evidence, file, requirement_id) when is_list(evidence) do
    Enum.flat_map(evidence, fn item -> validate_item(item, file, requirement_id) end)
  end

  def validate(_evidence, file, requirement_id) do
    [
      %{
        code: "invalid_evidence_list",
        severity: :error,
        file: file,
        requirement_id: requirement_id,
        message: "Evidence must be an array"
      }
    ]
  end

  @spec run([map()], String.t(), Keyword.t(), String.t()) :: [map()]
  def run(evidence, root, opts, requirement_id) do
    {findings, _cache} = run_with_cache(evidence, root, opts, requirement_id, %{})
    findings
  end

  @spec run_with_cache([map()], String.t(), Keyword.t(), String.t(), map()) :: {[map()], map()}
  def run_with_cache(evidence, root, opts, requirement_id, cache) do
    run_commands? = Keyword.get(opts, :run_commands, true)

    Enum.reduce(evidence, {[], cache}, fn item, {findings, acc_cache} ->
      {item_findings, next_cache} =
        run_item_with_cache(item, root, run_commands?, requirement_id, acc_cache)

      {findings ++ item_findings, next_cache}
    end)
  end

  defp validate_item(item, file, requirement_id) when is_map(item) do
    case item["kind"] do
      "path_exists" ->
        require_string(item, "path", file, requirement_id, "missing_evidence_path")

      "path_absent" ->
        require_string(item, "path", file, requirement_id, "missing_evidence_path")

      "path_glob_nonempty" ->
        require_string(item, "glob", file, requirement_id, "missing_evidence_glob")

      "command" ->
        []
        |> Kernel.++(require_string(item, "run", file, requirement_id, "missing_command_run"))
        |> Kernel.++(optional_string(item, "cwd", file, requirement_id, "invalid_command_cwd"))
        |> Kernel.++(
          optional_string(
            item,
            "expect_stdout_contains",
            file,
            requirement_id,
            "invalid_command_expect_stdout_contains"
          )
        )
        |> Kernel.++(
          optional_integer(
            item,
            "expect_exit_status",
            file,
            requirement_id,
            "invalid_command_expect_exit_status"
          )
        )

      kind when kind in @valid_kinds ->
        []

      kind ->
        [
          %{
            code: "invalid_evidence_kind",
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message:
              "Unsupported evidence kind #{inspect(kind)}. Expected one of #{Enum.join(@valid_kinds, ", ")}"
          }
        ]
    end
  end

  defp validate_item(_item, file, requirement_id) do
    [
      %{
        code: "invalid_evidence_shape",
        severity: :error,
        file: file,
        requirement_id: requirement_id,
        message: "Each evidence entry must be a JSON object"
      }
    ]
  end

  defp run_item(%{"kind" => "path_exists", "path" => path}, root, _run_commands?, requirement_id) do
    absolute_path = Path.expand(path, root)

    if File.exists?(absolute_path) do
      []
    else
      [
        %{
          code: "path_missing",
          severity: :error,
          requirement_id: requirement_id,
          path: path,
          message: "Expected path #{path} to exist"
        }
      ]
    end
  end

  defp run_item(%{"kind" => "path_absent", "path" => path}, root, _run_commands?, requirement_id) do
    absolute_path = Path.expand(path, root)

    if File.exists?(absolute_path) do
      [
        %{
          code: "path_present",
          severity: :error,
          requirement_id: requirement_id,
          path: path,
          message: "Expected path #{path} to be absent"
        }
      ]
    else
      []
    end
  end

  defp run_item(
         %{"kind" => "path_glob_nonempty", "glob" => glob},
         root,
         _run_commands?,
         requirement_id
       ) do
    if root |> Path.join(glob) |> Path.wildcard() |> Enum.any?() do
      []
    else
      [
        %{
          code: "glob_empty",
          severity: :error,
          requirement_id: requirement_id,
          glob: glob,
          message: "Expected glob #{glob} to match at least one path"
        }
      ]
    end
  end

  defp run_item(%{"kind" => "command"} = item, _root, false, requirement_id) do
    [
      %{
        code: "command_skipped",
        severity: :error,
        requirement_id: requirement_id,
        command: item["run"],
        message:
          "Command evidence #{inspect(item["run"])} was skipped because --no-run-commands was used"
      }
    ]
  end

  defp run_item(%{"kind" => "command"} = item, root, true, requirement_id) do
    cwd = Path.expand(item["cwd"] || ".", root)
    expected_exit_status = item["expect_exit_status"] || 0
    expected_stdout = item["expect_stdout_contains"]

    {output, exit_status} =
      System.cmd("zsh", ["-lc", item["run"]], cd: cwd, stderr_to_stdout: true)

    findings = []

    findings =
      if exit_status == expected_exit_status do
        findings
      else
        [
          %{
            code: "command_exit_status_mismatch",
            severity: :error,
            requirement_id: requirement_id,
            command: item["run"],
            message:
              "Expected command #{inspect(item["run"])} to exit with #{expected_exit_status}, got #{exit_status}"
          }
          | findings
        ]
      end

    findings =
      if is_binary(expected_stdout) and not String.contains?(output, expected_stdout) do
        [
          %{
            code: "command_stdout_mismatch",
            severity: :error,
            requirement_id: requirement_id,
            command: item["run"],
            message:
              "Expected command #{inspect(item["run"])} output to include #{inspect(expected_stdout)}"
          }
          | findings
        ]
      else
        findings
      end

    Enum.reverse(findings)
  end

  defp run_item(_item, _root, _run_commands?, _requirement_id), do: []

  defp run_item_with_cache(
         %{"kind" => "command"} = item,
         root,
         run_commands?,
         requirement_id,
         cache
       ) do
    key = command_cache_key(item, root, run_commands?)

    case Map.fetch(cache, key) do
      {:ok, cached_findings} ->
        {restore_requirement_id(cached_findings, requirement_id), cache}

      :error ->
        findings = run_item(item, root, run_commands?, requirement_id)
        {findings, Map.put(cache, key, strip_requirement_id(findings))}
    end
  end

  defp run_item_with_cache(item, root, run_commands?, requirement_id, cache) do
    {run_item(item, root, run_commands?, requirement_id), cache}
  end

  defp command_cache_key(item, root, run_commands?) do
    {
      run_commands?,
      Path.expand(item["cwd"] || ".", root),
      item["run"],
      item["expect_exit_status"] || 0,
      item["expect_stdout_contains"]
    }
  end

  defp strip_requirement_id(findings) do
    Enum.map(findings, &Map.delete(&1, :requirement_id))
  end

  defp restore_requirement_id(findings, requirement_id) do
    Enum.map(findings, &Map.put(&1, :requirement_id, requirement_id))
  end

  defp require_string(map, key, file, requirement_id, code) do
    case map[key] do
      value when is_binary(value) and value != "" ->
        []

      _ ->
        [
          %{
            code: code,
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message: "Expected #{key} to be a non-empty string"
          }
        ]
    end
  end

  defp optional_string(map, key, file, requirement_id, code) do
    case Map.get(map, key) do
      nil ->
        []

      value when is_binary(value) ->
        []

      _ ->
        [
          %{
            code: code,
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message: "Expected #{key} to be a string"
          }
        ]
    end
  end

  defp optional_integer(map, key, file, requirement_id, code) do
    case Map.get(map, key) do
      nil ->
        []

      value when is_integer(value) ->
        []

      _ ->
        [
          %{
            code: code,
            severity: :error,
            file: file,
            requirement_id: requirement_id,
            message: "Expected #{key} to be an integer"
          }
        ]
    end
  end
end
