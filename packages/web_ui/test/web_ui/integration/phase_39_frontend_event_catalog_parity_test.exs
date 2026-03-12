defmodule WebUi.Integration.Phase39FrontendEventCatalogParityTest do
  use ExUnit.Case, async: true

  alias WebUi.Events.EventCatalog

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-044 frontend event catalog validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_catalog_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event catalog contract validation passed."
  end

  test "SCN-044 frontend harness references canonical widget event types and typed invalid-type guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    for event_type <- EventCatalog.all_event_types() do
      assert main_elm =~ "\"#{event_type}\""
      assert bridge_js =~ "\"#{event_type}\""
    end

    assert bridge_js =~ "CANONICAL_WIDGET_EVENT_TYPES.includes(eventEnvelope.type)"
    assert bridge_js =~ "transport.invalid_widget_event_type"
  end

  test "SCN-044 gate wiring includes frontend event catalog contract validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_catalog_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_catalog_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_catalog_contract.sh"
  end
end
