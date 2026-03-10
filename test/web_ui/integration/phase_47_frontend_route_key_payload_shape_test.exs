defmodule WebUi.Integration.Phase47FrontendRouteKeyPayloadShapeTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-052 frontend route-key payload-shape validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_shape_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key payload-shape validation passed."
  end

  test "SCN-052 frontend harness preserves route-key payload-shape continuity and invalid-value guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "canonicalRouteKeyShape"
    assert main_elm =~ "uniqueRouteKeys"
    assert main_elm =~ "appendIfUniqueRouteKey"

    assert bridge_js =~ "analyzeDeclaredRouteKeys"
    assert bridge_js =~ "routeKeyValueType"
    assert bridge_js =~ "expected_value_shape"
    assert bridge_js =~ "actual_value_shape"
    assert bridge_js =~ "invalid_route_keys"
    assert bridge_js =~ "invalid key values for route family"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
  end

  test "SCN-052 gate wiring includes frontend route-key payload-shape validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_shape_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_shape_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_shape_contract.sh"
  end
end
