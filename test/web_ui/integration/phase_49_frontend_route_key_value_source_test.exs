defmodule WebUi.Integration.Phase49FrontendRouteKeyValueSourceTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-054 frontend route-key value-source validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_source_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key value-source validation passed."
  end

  test "SCN-054 frontend harness preserves route-key value-source continuity and invalid-source guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "routeFamilySourceContinuityFields"
    assert main_elm =~ "canonicalRouteKeySource"
    assert main_elm =~ "canonicalRouteKeyResolution"
    assert main_elm =~ "routeKeyContractResolution"
    assert main_elm =~ "widgetRouteKeyResolution"
    assert main_elm =~ "route_key_sources"

    assert bridge_js =~ "CANONICAL_ROUTE_KEY_SOURCE_VALUES"
    assert bridge_js =~ "CANONICAL_ROUTE_KEY_SOURCE_REQUIREMENTS"
    assert bridge_js =~ "analyzeDeclaredRouteKeySources"
    assert bridge_js =~ "expected_route_key_sources"
    assert bridge_js =~ "source_mismatches"
    assert bridge_js =~ "route_key_sources payload mismatch for route family"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
  end

  test "SCN-054 gate wiring includes frontend route-key value-source validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_source_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_source_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_source_contract.sh"
  end
end
