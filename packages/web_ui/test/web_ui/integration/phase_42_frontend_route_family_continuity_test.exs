defmodule WebUi.Integration.Phase42FrontendRouteFamilyContinuityTest do
  use ExUnit.Case, async: true

  alias WebUi.Events.EventCatalog

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-047 frontend route-family continuity validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_family_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-family contract validation passed."
  end

  test "SCN-047 frontend harness preserves canonical route-family continuity and typed mismatch guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    for event_type <- EventCatalog.all_event_types() do
      {:ok, route_family} = EventCatalog.route_family(event_type)
      assert main_elm =~ "( \"#{event_type}\", \"#{route_family}\" )"
      assert bridge_js =~ "\"#{event_type}\": \"#{route_family}\""
    end

    assert main_elm =~ "( \"route_family\", Encode.string defaultWidgetEventRouteFamily )"
    assert main_elm =~ "routeFamilyForEventType defaultWidgetEventType"

    assert bridge_js =~ "declaredRouteFamily"
    assert bridge_js =~ "transport.invalid_widget_event_route_family"
    assert bridge_js =~ "expected_route_family"
    assert bridge_js =~ "actual_route_family"
  end

  test "SCN-047 gate wiring includes frontend route-family continuity validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_family_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_family_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_family_contract.sh"
  end
end
