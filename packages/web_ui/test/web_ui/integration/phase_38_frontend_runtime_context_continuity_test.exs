defmodule WebUi.Integration.Phase38FrontendRuntimeContextContinuityTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-043 frontend runtime-context validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_runtime_context_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend runtime-context contract validation passed."
  end

  test "SCN-043 frontend harness includes required and optional runtime-context fields" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    for field <- ["correlation_id", "request_id", "session_id", "client_id", "user_id", "trace_id"] do
      assert main_elm =~ "\"#{field}\""
      assert bridge_js =~ "\"#{field}\""
    end

    assert bridge_js =~ "normalizeRuntimeContext"
    assert bridge_js =~ "context: runtimeContext"
  end

  test "SCN-043 gate wiring includes frontend runtime-context contract validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_runtime_context_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_runtime_context_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_runtime_context_contract.sh"
  end
end
