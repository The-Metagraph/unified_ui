defmodule WebUi.Integration.Phase54FrontendRouteKeySourceTriadParityTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-059 frontend route-key source triad parity validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_source_triad_parity_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key source triad parity validation passed."
  end

  test "SCN-059 frontend harness preserves source triad parity and mismatch guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "declaredRouteKeySourceTriadParityKeys"
    assert main_elm =~ "declaredRouteKeySourceTriadEntries"
    assert main_elm =~ "route_keys"
    assert main_elm =~ "route_key_source_keys"
    assert main_elm =~ "route_key_sources"

    assert bridge_js =~ "analyzeRouteKeySourceTriadParity"
    assert bridge_js =~ "route_key source triad parity mismatch for route family"
    assert bridge_js =~ "route_key_source_key_mismatches"
    assert bridge_js =~ "route_key_source_map_key_mismatches"
    assert bridge_js =~ "source_key_source_map_key_mismatches"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
  end

  test "SCN-059 gate wiring includes frontend route-key source triad parity validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_source_triad_parity_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_source_triad_parity_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_source_triad_parity_contract.sh"
  end
end
