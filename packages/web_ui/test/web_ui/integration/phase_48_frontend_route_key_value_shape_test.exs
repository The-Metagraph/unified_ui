defmodule WebUi.Integration.Phase48FrontendRouteKeyValueShapeTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-053 frontend route-key value-shape validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_value_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key value-shape validation passed."
  end

  test "SCN-053 frontend harness preserves route-key value-shape continuity and invalid-value guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "canonicalRouteKeyValue"
    assert main_elm =~ "routeKeyContractStringValue"
    assert main_elm =~ "widgetRouteKeyStringValue"
    assert main_elm =~ "nonEmptyString"

    assert bridge_js =~ "analyzeRequiredRouteKeyValues"
    assert bridge_js =~ "expected_route_key_value_shape"
    assert bridge_js =~ "invalid_route_key_values"
    assert bridge_js =~ "route-key payload values must be non-empty strings for route family"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
  end

  test "SCN-053 gate wiring includes frontend route-key value-shape validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_value_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_value_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_value_contract.sh"
  end
end
