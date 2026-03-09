defmodule WebUi.Integration.Phase36FrontendTransportContractParityTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-041 frontend transport validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_transport_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend transport contract validation passed."
  end

  test "SCN-041 Elm and JS harness avoid non-canonical join/joined event names" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    refute main_elm =~ "runtime.event.join.v1"
    refute main_elm =~ "runtime.event.joined.v1"
    refute bridge_js =~ "runtime.event.join.v1"
    refute bridge_js =~ "runtime.event.joined.v1"
  end

  test "SCN-041 gate wiring includes frontend transport contract validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_transport_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_transport_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_transport_contract.sh"
  end
end
