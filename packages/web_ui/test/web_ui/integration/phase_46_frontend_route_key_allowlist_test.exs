defmodule WebUi.Integration.Phase46FrontendRouteKeyAllowlistTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-051 frontend route-key allowlist validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_allowlist_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key allowlist validation passed."
  end

  test "SCN-051 frontend harness preserves route-key allowlist continuity and unexpected-key guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "routeFamilyCompatibilityRouteKeys"
    assert main_elm =~ "isAllowedRouteKey"
    assert main_elm =~ "routeFamilyCompatibilityFields model"

    assert bridge_js =~ "unexpectedRouteKeys"
    assert bridge_js =~ "unexpected_route_keys"
    assert bridge_js =~ "allowed_route_keys"
    assert bridge_js =~ "non-canonical route keys for route family"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
  end

  test "SCN-051 gate wiring includes frontend route-key allowlist validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_allowlist_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_allowlist_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_allowlist_contract.sh"
  end
end
