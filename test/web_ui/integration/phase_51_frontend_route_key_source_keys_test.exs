defmodule WebUi.Integration.Phase51FrontendRouteKeySourceKeysTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-056 frontend route-key source-key validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_source_keys_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key source-key validation passed."
  end

  test "SCN-056 frontend harness preserves route-key source-key continuity and mismatch guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "routeFamilySourceKeyContinuityFields"
    assert main_elm =~ "declaredRouteKeySourceEntries"
    assert main_elm =~ "declaredRouteKeySourceKeys"
    assert main_elm =~ "route_key_source_keys"

    assert bridge_js =~ "analyzeDeclaredRouteKeySourceKeys"
    assert bridge_js =~ "expected_route_key_source_keys"
    assert bridge_js =~ "actual_route_key_source_keys"
    assert bridge_js =~ "duplicate_route_key_source_keys"
    assert bridge_js =~ "route_key_source_keys payload mismatch for route family"
    assert bridge_js =~ "route_key_source_keys payload mismatch with route_key_sources entries for route family"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
  end

  test "SCN-056 gate wiring includes frontend route-key source-key validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_source_keys_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_source_keys_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_source_keys_contract.sh"
  end
end
