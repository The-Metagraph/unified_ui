defmodule WebUi.Integration.Phase34FrontendToolchainEnforcementTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-039 script report-only mode validates frontend toolchain wiring" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_toolchain.sh", "--report-only"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend toolchain wiring checks passed"
  end

  test "SCN-039 git hooks enforce frontend validation boundaries" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))

    assert pre_commit =~ "./scripts/validate_frontend_toolchain.sh --report-only"
    assert pre_push =~ "./scripts/validate_frontend_toolchain.sh --skip-install"
  end

  test "SCN-039 CI workflow runs pinned frontend toolchain validation" do
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert workflow =~ "uses: actions/setup-node@v4"
    assert workflow =~ "node-version: \"22.14.0\""
    assert workflow =~ "cache-dependency-path: assets/package-lock.json"
    assert workflow =~ "run: ./scripts/validate_frontend_toolchain.sh"
  end
end
