defmodule WebUi.Integration.Phase41FrontendEventRouteContractParityTest do
  use ExUnit.Case, async: true

  alias WebUi.Events.EventCatalog

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-046 frontend route contract validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route contract validation passed."
  end

  test "SCN-046 frontend harness references canonical route families/keys and typed invalid-route guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    for event_type <- EventCatalog.all_event_types() do
      {:ok, route_family} = EventCatalog.route_family(event_type)
      assert bridge_js =~ "\"#{event_type}\": \"#{route_family}\""
    end

    for route_key <- ["action", "button_id", "widget_id", "id", "input_id", "field", "form_id"] do
      assert main_elm =~ "\"#{route_key}\""
      assert bridge_js =~ "\"#{route_key}\""
    end

    assert main_elm =~ "defaultWidgetEventRouteFamily"
    assert bridge_js =~ "CANONICAL_WIDGET_EVENT_ROUTE_FAMILIES"
    assert bridge_js =~ "CANONICAL_ROUTE_KEY_REQUIREMENTS"
    assert bridge_js =~ "validateWidgetEventRouteKeys"
    assert bridge_js =~ "transport.invalid_widget_event_route"
  end

  test "SCN-046 gate wiring includes frontend route contract validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_contract.sh"
  end
end
