defmodule WebUi.Integration.Phase40FrontendEventPayloadContractParityTest do
  use ExUnit.Case, async: true

  alias WebUi.Events.EventCatalog

  @moduletag :conformance

  @root Path.expand("../../..", __DIR__)

  test "SCN-045 frontend payload contract validator passes for canonical harness state" do
    {output, status} =
      System.cmd(
        "bash",
        ["./scripts/validate_frontend_event_payload_contract.sh"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert status == 0
    assert output =~ "Frontend widget event payload contract validation passed."
  end

  test "SCN-045 frontend harness references canonical payload keys and typed invalid-payload guardrails" do
    main_elm = File.read!(Path.join(@root, "assets/src/Main.elm"))
    bridge_js = File.read!(Path.join(@root, "assets/js/app.js"))

    required_payload_keys =
      EventCatalog.all_event_types()
      |> Enum.flat_map(fn event_type ->
        {:ok, key_spec} = EventCatalog.required_key_spec(event_type)
        key_spec.required_all_of ++ List.flatten(key_spec.required_any_of)
      end)
      |> Enum.uniq()

    for key <- required_payload_keys do
      assert main_elm =~ "\"#{key}\""
      assert bridge_js =~ "\"#{key}\""
    end

    assert bridge_js =~ "CANONICAL_WIDGET_EVENT_KEY_SPECS"
    assert bridge_js =~ "validateWidgetEventPayload"
    assert bridge_js =~ "transport.invalid_widget_event_payload"
  end

  test "SCN-045 gate wiring includes frontend payload contract validation" do
    pre_commit = File.read!(Path.join(@root, ".githooks/pre-commit"))
    pre_push = File.read!(Path.join(@root, ".githooks/pre-push"))
    workflow = File.read!(Path.join(@root, ".github/workflows/frontend-toolchain.yml"))

    assert pre_commit =~ "./scripts/validate_frontend_event_payload_contract.sh"
    assert pre_push =~ "./scripts/validate_frontend_event_payload_contract.sh"
    assert workflow =~ "run: ./scripts/validate_frontend_event_payload_contract.sh"
  end
end
