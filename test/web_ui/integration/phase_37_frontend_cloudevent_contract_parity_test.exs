defmodule WebUi.Integration.Phase37FrontendCloudEventContractParityTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-042 frontend CloudEvent validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_cloudevent_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend CloudEvent contract validation passed."
  end

  test "SCN-042 frontend harness includes required CloudEvent fields/extensions and typed invalid-envelope error code" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    for field <- ["specversion", "id", "source", "type", "data"] do
      assert main_elm =~ "\"#{field}\""
      assert bridge_js =~ "\"#{field}\""
    end

    for extension <- ["correlation_id", "request_id"] do
      assert main_elm =~ "\"#{extension}\""
      assert bridge_js =~ "\"#{extension}\""
    end

    assert bridge_js =~ "transport.invalid_cloudevent_envelope"
  end

  test "SCN-042 gate wiring includes frontend CloudEvent contract validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_cloudevent_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_cloudevent_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_cloudevent_contract.sh"
  end
end
