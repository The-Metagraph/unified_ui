defmodule WebUi.Integration.Phase45FrontendRouteKeyCompletenessTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-050 frontend route-key completeness validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_completeness_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key completeness validation passed."
  end

  test "SCN-050 frontend harness preserves required route-key completeness guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "routeFamilyRequirementValue"
    assert main_elm =~ "widgetEventContractValue model key"
    assert main_elm =~ "routeFamilyRequirementKeys defaultWidgetEventRouteFamily"

    assert bridge_js =~ "missingRouteKeys"
    assert bridge_js =~ "missing_route_keys"
    assert bridge_js =~ "missing required route keys for route family"
    assert bridge_js =~ "expected_route_keys: requiredRouteKeys"
    assert bridge_js =~ "actual_route_keys: presentRouteKeys"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
  end

  test "SCN-050 gate wiring includes frontend route-key completeness validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_completeness_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_completeness_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_completeness_contract.sh"
  end
end
