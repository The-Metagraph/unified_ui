defmodule WebUi.Integration.Phase14ReleaseGateRegressionTest do
  use ExUnit.Case, async: false

  @root Path.expand("../../..", __DIR__)

  @component_coverage_row "| `specs/operations/rfc_intake_governance.md` | `AC-*` | `REQ-CP-*`, `REQ-OBS-*` | `SCN-001`, `SCN-006` |"

  @moduletag :conformance

  test "SCN-019 report-only release gate emits deterministic stage/result markers" do
    {output, status} = run_release_gate(@root, ["--report-only"])

    assert status == 0
    assert output =~ "RELEASE_GATE_STAGE=1_specs_governance:start"
    assert output =~ "RELEASE_GATE_STAGE=1_specs_governance:pass"
    assert output =~ "RELEASE_GATE_STAGE=5_full_tests:skipped_report_only"
    assert output =~ "RELEASE_GATE_RESULT=PASS"
  end

  test "SCN-019 regression probe script passes on clean workspace inputs" do
    {output, status} = run_regression_probe(@root)

    assert status == 0
    assert output =~ "Release gate regression checks passed."
  end

  test "SCN-019 injected unknown scenario defect fails release gate with governance diagnostics" do
    unknown_id = scenario_id(999)

    with_temp_worktree(fn worktree_root ->
      matrix_path = Path.join(worktree_root, "specs/conformance/spec_conformance_matrix.md")

      File.write!(
        matrix_path,
        File.read!(matrix_path)
        |> String.replace(
          @component_coverage_row,
          "| `specs/operations/rfc_intake_governance.md` | `AC-*` | `REQ-CP-*`, `REQ-OBS-*` | `SCN-001`, `SCN-006`, `#{unknown_id}` |",
          global: false
        )
      )

      {output, status} = run_release_gate(worktree_root, ["--report-only"])

      assert status == 1
      assert output =~ unknown_id
      assert output =~ "Governance validation failed"
      refute output =~ "RELEASE_GATE_RESULT=PASS"
    end)
  end

  defp run_release_gate(root, args) when is_binary(root) and is_list(args) do
    System.cmd(
      "bash",
      ["./scripts/run_release_readiness.sh" | args],
      cd: root,
      env: [{"MIX_ENV", "test"}],
      stderr_to_stdout: true
    )
  end

  defp run_regression_probe(root) when is_binary(root) do
    System.cmd(
      "bash",
      ["./scripts/check_release_gate_regressions.sh"],
      cd: root,
      env: [{"MIX_ENV", "test"}],
      stderr_to_stdout: true
    )
  end

  defp with_temp_worktree(test_fun) do
    unique = System.unique_integer([:positive])
    worktree_path = Path.join(System.tmp_dir!(), "web_ui_phase14_worktree_#{unique}")

    {_, add_status} =
      System.cmd(
        "git",
        ["worktree", "add", "--detach", worktree_path, "HEAD"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert add_status == 0

    on_exit(fn ->
      System.cmd(
        "git",
        ["worktree", "remove", "--force", worktree_path],
        cd: @root,
        stderr_to_stdout: true
      )
    end)

    test_fun.(worktree_path)
  end

  defp scenario_id(number) when is_integer(number) and number > 0 do
    "SCN-" <> (number |> Integer.to_string() |> String.pad_leading(3, "0"))
  end
end
