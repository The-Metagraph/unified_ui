defmodule WebUi.Integration.Phase09RfcGovernanceOperationsTest do
  use ExUnit.Case, async: false

  @root Path.expand("../../..", __DIR__)
  @rfc_primary Path.join(@root, "rfcs/RFC-0001-rfc-governance-and-spec-intake.md")

  test "validator fails for missing metadata sections with explicit diagnostics" do
    with_file_patch(
      @rfc_primary,
      fn original ->
        String.replace(original, "## Metadata", "## Metadata Missing", global: false)
      end,
      fn ->
        {output, status} = run_validator()

        assert status == 1
        assert output =~ "missing required section '## Metadata'"
        assert output =~ "RFC-0001-rfc-governance-and-spec-intake.md"
      end
    )
  end

  test "validator fails deterministically for unknown req/scn/contract references" do
    unknown_req = "REQ-" <> "ZZZ" <> "-*"
    unknown_scn = scenario_id(999)
    unknown_contract = "specs/contracts/missing_contract_for_phase_09.md"

    with_file_patch(
      @rfc_primary,
      fn original ->
        String.replace(
          original,
          "### Contract References\n\n- [control_plane_ownership_matrix.md](../specs/contracts/control_plane_ownership_matrix.md)",
          "### Contract References\n\n- [control_plane_ownership_matrix.md](../specs/contracts/control_plane_ownership_matrix.md)\n- [missing_contract_for_phase_09.md](../#{unknown_contract})",
          global: false
        )
        |> String.replace("- `REQ-CP-*`", "- `REQ-CP-*`\n- `#{unknown_req}`", global: false)
        |> String.replace("- `#{scenario_id(6)}`", "- `#{scenario_id(6)}`\n- `#{unknown_scn}`",
          global: false
        )
      end,
      fn ->
        {output, status} = run_validator()

        assert status == 1
        assert output =~ "unknown REQ family 'REQ-ZZZ'"
        assert output =~ "unknown SCN id '#{unknown_scn}'"
        assert output =~ "missing contract path #{unknown_contract}"
      end
    )
  end

  test "accepted rfc changes without specs deltas fail governance gate" do
    with_temp_worktree(fn worktree_root ->
      rfc_id = "RFC-1999"
      slug = "phase-09-accepted-gate"
      rfc_rel = "rfcs/#{rfc_id}-#{slug}.md"
      spec_rel = "specs/tmp/#{slug}.md"
      rfc_path = Path.join(worktree_root, rfc_rel)
      index_path = Path.join(worktree_root, "rfcs/index.md")

      File.write!(rfc_path, temp_rfc_content(rfc_id, spec_rel, slug, "Accepted"))

      File.write!(
        index_path,
        File.read!(index_path) <>
          "\n| `#{rfc_id}` | Phase 09 Accepted Gate | Accepted | @integration | 1 `create` row | none | none | Fixture RFC for accepted gate validation. |\n"
      )

      {_, add_status} =
        System.cmd("git", ["add", rfc_rel, "rfcs/index.md"], cd: worktree_root, stderr_to_stdout: true)

      assert add_status == 0

      {output, status} = run_validator(worktree_root)

      assert status == 1
      assert output =~ "accepted/implemented RFC changes require at least one specs/*.md change"
    end)
  end

  test "generator dry-run output reflects expected create rows without file writes" do
    with_temp_rfc("dry-run", fn rfc_path, spec_rel, spec_path ->
      {output, status} = run_generator(["--rfc", rfc_path, "--dry-run"])

      assert status == 0
      assert output =~ "DRY RUN: would write #{spec_rel}"
      refute File.exists?(spec_path)
    end)
  end

  test "generator create rows produce governance-compliant spec stubs" do
    with_temp_rfc("create", fn rfc_path, spec_rel, spec_path ->
      {output, status} = run_generator(["--rfc", rfc_path])

      assert status == 0
      assert output =~ "CREATED: #{spec_rel}"
      assert output =~ "Verified stubs: 1"
      assert File.exists?(spec_path)

      content = File.read!(spec_path)
      assert content =~ "## Governance Mapping"
      assert content =~ "## Acceptance Criteria"
      assert content =~ "## Normative Contracts"
    end)
  end

  test "generator skip and overwrite behavior is deterministic" do
    with_temp_rfc("overwrite", fn rfc_path, spec_rel, spec_path ->
      File.write!(spec_path, "# Original\n\nmarker: keep\n")

      {skip_output, skip_status} = run_generator(["--rfc", rfc_path])
      assert skip_status == 0
      assert skip_output =~ "SKIP: #{spec_rel} already exists"
      assert File.read!(spec_path) =~ "marker: keep"

      {overwrite_output, overwrite_status} = run_generator(["--rfc", rfc_path, "--overwrite"])
      assert overwrite_status == 0
      assert overwrite_output =~ "CREATED: #{spec_rel}"
      refute File.read!(spec_path) =~ "marker: keep"
      assert File.read!(spec_path) =~ "## Control Plane"
    end)
  end

  defp run_validator(root \\ @root) do
    System.cmd(
      "bash",
      ["./scripts/validate_rfc_governance.sh"],
      cd: root,
      stderr_to_stdout: true
    )
  end

  defp run_generator(args) do
    System.cmd(
      "bash",
      ["./scripts/gen_specs_from_rfc.sh" | args],
      cd: @root,
      stderr_to_stdout: true
    )
  end

  defp with_file_patch(path, patch_fun, test_fun) do
    original = File.read!(path)

    on_exit(fn ->
      File.write!(path, original)
    end)

    original
    |> patch_fun.()
    |> then(&File.write!(path, &1))

    test_fun.()
  end

  defp with_temp_rfc(suffix, test_fun) do
    id_number =
      System.unique_integer([:positive])
      |> rem(9000)
      |> Kernel.+(1000)

    rfc_id = "RFC-" <> String.pad_leading(Integer.to_string(id_number), 4, "0")
    slug = "phase-09-#{suffix}-#{id_number}"

    rfc_rel = "rfcs/#{rfc_id}-#{slug}.md"
    spec_rel = "specs/tmp/#{slug}.md"

    rfc_path = Path.join(@root, rfc_rel)
    spec_path = Path.join(@root, spec_rel)

    File.mkdir_p!(Path.dirname(rfc_path))
    File.mkdir_p!(Path.dirname(spec_path))

    File.write!(rfc_path, temp_rfc_content(rfc_id, spec_rel, slug))

    on_exit(fn ->
      File.rm(rfc_path)
      File.rm(spec_path)
    end)

    test_fun.(rfc_rel, spec_rel, spec_path)
  end

  defp with_temp_worktree(test_fun) do
    unique = System.unique_integer([:positive])
    worktree_path = Path.join(System.tmp_dir!(), "web_ui_phase09_worktree_#{unique}")

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

  defp temp_rfc_content(rfc_id, spec_rel, slug, status \\ "Draft") do
    """
    # #{rfc_id}: Phase 09 #{slug}

    ## Metadata

    - RFC ID: `#{rfc_id}`
    - Status: `#{status}`
    - Authors: `@integration`
    - Created: `2026-03-07`
    - Target Phase: `Phase-9`
    - Supersedes: `none`
    - Superseded By: `none`

    ## Summary

    Temporary RFC fixture for integration tests.

    ## Motivation

    Validate governance tooling behavior.

    ## Scope

    In scope:

    - tooling validation

    Out of scope:

    - production behavior changes

    ## Proposed Design

    Use RFC plan rows to generate and validate deterministic spec stubs.

    ## Governance Mapping

    ### Requirement Families (`REQ-*`)

    - `REQ-CP-*`
    - `REQ-OBS-*`

    ### Scenario Coverage (`SCN-*`)

    - `#{scenario_id(1)}`
    - `#{scenario_id(6)}`

    ### Contract References

    - [control_plane_ownership_matrix.md](../specs/contracts/control_plane_ownership_matrix.md)
    - [observability_contract.md](../specs/contracts/observability_contract.md)

    ### ADR Impact

    - ADR update required: `no`
    - ADR refs: `none`

    ### Lifecycle Impact

    - Transition: `none`
    - Index row updated: `no`

    ## Spec Creation Plan

    | Action | Spec Path | Component Title | Control Plane | Requirement Families | Scenario IDs | Initial AC IDs |
    |---|---|---|---|---|---|---|
    | create | #{spec_rel} | Temp #{slug} | Product Plane | REQ-CP-*, REQ-OBS-* | #{scenario_id(1)}, #{scenario_id(6)} | AC-01, AC-02 |

    ## Migration / Rollout

    Not applicable.

    ## Risks

    Temporary test fixture only.

    ## Open Questions

    - none
    """
  end

  defp scenario_id(number) when is_integer(number) and number > 0 do
    "SCN-" <> (number |> Integer.to_string() |> String.pad_leading(3, "0"))
  end
end
