defmodule WebUi.Integration.Phase58SpecsGovernanceChangePolicyTest do
  use ExUnit.Case, async: false

  @root Path.expand("../../..", __DIR__)
  @moduletag :conformance

  test "SCN-019 AC-bearing component changes fail without contract and matrix updates" do
    with_temp_worktree(fn worktree_root ->
      component_spec_path = Path.join(worktree_root, "specs/operations/rfc_intake_governance.md")

      File.write!(
        component_spec_path,
        File.read!(component_spec_path) <>
          "\n<!-- phase-58 governance probe: deterministic MUST guardrail -->\n"
      )

      {output, status} = run_governance_validator(worktree_root)

      assert status == 1

      assert output =~
               "AC-bearing component spec changes require at least one contract update in specs/contracts."

      assert output =~ "AC-bearing component spec changes require conformance matrix updates."
      assert output =~ "Governance validation failed."
    end)
  end

  test "SCN-019 non-AC conformance doc changes do not trigger AC-change coupling failures" do
    with_temp_worktree(fn worktree_root ->
      conformance_doc_path =
        Path.join(worktree_root, "specs/conformance/phase-01-integration-scenarios.md")

      File.write!(
        conformance_doc_path,
        File.read!(conformance_doc_path) <>
          "\n<!-- phase-58 conformance doc probe -->\n"
      )

      {output, status} = run_governance_validator(worktree_root)

      assert status == 0
      assert output =~ "Governance validation passed."

      refute output =~
               "AC-bearing component spec changes require at least one contract update in specs/contracts."
    end)
  end

  defp run_governance_validator(root) when is_binary(root) do
    System.cmd(
      "bash",
      ["./scripts/validate_specs_governance.sh"],
      cd: root,
      env: [{"MIX_ENV", "test"}],
      stderr_to_stdout: true
    )
  end

  defp with_temp_worktree(test_fun) do
    unique = System.unique_integer([:positive])
    worktree_path = Path.join(System.tmp_dir!(), "web_ui_phase58_worktree_#{unique}")

    {_, add_status} =
      System.cmd(
        "git",
        ["worktree", "add", "--detach", worktree_path, "HEAD"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert add_status == 0

    # Ensure the probe exercises the current workspace validator implementation,
    # including local changes not yet committed.
    workspace_script = Path.join(@root, "scripts/validate_specs_governance.sh")
    worktree_script = Path.join(worktree_path, "scripts/validate_specs_governance.sh")
    File.cp!(workspace_script, worktree_script)
    File.chmod!(worktree_script, 0o755)

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
end
