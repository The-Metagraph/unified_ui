defmodule WebUi.Integration.Phase53FrontendRouteKeySourceMapParityTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-058 frontend route-key source-map parity validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_source_map_parity_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key source-map parity validation passed."
  end

  test "SCN-058 frontend harness preserves source-map key to route-key parity and mismatch guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "declaredRouteKeySourceMapParityKeys"
    assert main_elm =~ "route_key_sources"
    assert main_elm =~ "route_key_source_keys"

    assert bridge_js =~ "analyzeRouteKeySourceMapKeyParityWithRouteKeys"
    assert bridge_js =~ "source_map_key_parity_mismatches"
    assert bridge_js =~ "route_key_sources payload key mismatch with route_keys payload for route family"
    assert bridge_js =~ "route_key_sources_keys:"
    assert bridge_js =~ "route_keys:"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
  end

  test "SCN-058 gate wiring includes frontend route-key source-map parity validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_source_map_parity_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_source_map_parity_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_source_map_parity_contract.sh"
  end
end
