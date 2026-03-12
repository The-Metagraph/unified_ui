defmodule WebUi.Integration.Phase43FrontendRouteKeysContinuityTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-048 frontend route-keys continuity validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_keys_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-keys contract validation passed."
  end

  test "SCN-048 frontend harness preserves route_keys continuity and typed mismatch guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    for route_key <- ["action", "button_id", "widget_id", "id", "input_id", "field", "form_id"] do
      assert main_elm =~ "\"#{route_key}\""
      assert bridge_js =~ "\"#{route_key}\""
    end

    assert main_elm =~ "\"route_keys\""
    assert main_elm =~ "declaredRouteKeys"
    assert main_elm =~ "isRouteKeyPopulated"

    assert bridge_js =~ "route_keys"
    assert bridge_js =~ "normalizedStringList"
    assert bridge_js =~ "declaredRouteKeys"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
    assert bridge_js =~ "expected_route_keys"
    assert bridge_js =~ "actual_route_keys"
  end

  test "SCN-048 gate wiring includes frontend route-keys continuity validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_keys_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_keys_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_keys_contract.sh"
  end
end
