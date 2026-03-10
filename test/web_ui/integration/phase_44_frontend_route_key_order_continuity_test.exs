defmodule WebUi.Integration.Phase44FrontendRouteKeyOrderContinuityTest do
  use ExUnit.Case, async: true

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-049 frontend route-key ordering validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_route_key_order_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event route-key ordering validation passed."
  end

  test "SCN-049 frontend harness preserves ordered route_keys continuity and duplicate/order mismatch guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    assert main_elm =~ "List.foldl (appendIfRouteKeyPopulated model) []"
    assert main_elm =~ "List.reverse"
    assert main_elm =~ "( \"click\", [ \"action\", \"button_id\", \"widget_id\", \"id\" ] )"
    assert main_elm =~ "( \"change\", [ \"input_id\", \"widget_id\", \"field\", \"action\", \"id\" ] )"
    assert main_elm =~ "( \"submit\", [ \"form_id\", \"action\", \"id\" ] )"

    assert bridge_js =~ "click: [\"action\", \"button_id\", \"widget_id\", \"id\"]"
    assert bridge_js =~ "change: [\"input_id\", \"widget_id\", \"field\", \"action\", \"id\"]"
    assert bridge_js =~ "submit: [\"form_id\", \"action\", \"id\"]"
    assert bridge_js =~ "duplicateStrings"
    assert bridge_js =~ "duplicate_route_keys"
    assert bridge_js =~ "transport.invalid_widget_event_route_keys"
    assert bridge_js =~ "expectedRouteKeys.every((expectedKey, index) => expectedKey === actualRouteKeys[index])"
    refute bridge_js =~ "[...presentRouteKeys].sort()"
    refute bridge_js =~ "[...declaredRouteKeys].sort()"
  end

  test "SCN-049 gate wiring includes frontend route-key ordering validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_route_key_order_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_route_key_order_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_route_key_order_contract.sh"
  end
end
