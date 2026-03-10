defmodule WebUi.Integration.Phase50FrontendRouteKeySourceRequirementsTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-055 frontend route-key source-requirements validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_source_requirements_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key source-requirements validation passed."
  end

  test "SCN-055 frontend harness preserves route-key source-requirements continuity and drift guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "canonicalRouteKeySourceRequirements"
    assert main_elm =~ "canonicalRouteKeySourceForFamily"
    assert main_elm =~ "routeFamilyExpectedRouteKeySource"
    assert main_elm =~ "route_key_sources"

    assert bridge_js =~ "analyzeRouteKeySourceRequirements"
    assert bridge_js =~ "missing_route_key_source_requirements"
    assert bridge_js =~ "invalid_route_key_source_requirements"
    assert bridge_js =~ "canonical route_key source requirements drift for route family"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
  end

  test "SCN-055 gate wiring includes frontend route-key source-requirements validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_source_requirements_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_source_requirements_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_source_requirements_contract.sh"
  end
end
