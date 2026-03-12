defmodule WebUi.FirstSlice.WorkflowTest do
  use ExUnit.Case, async: true

  alias WebUi.Agent
  alias WebUi.FirstSlice.Workflow
  alias WebUi.ServiceRequestEnvelope

  test "builds canonical agent route for first slice" do
    assert {:ok, %Agent{} = runtime_agent} = Workflow.agent()

    assert {:ok, route_result} =
             Agent.dispatch_result(
               runtime_agent,
               %{
                 specversion: "1.0",
                 id: "evt-fs-001",
                 source: "webui.workflow_test",
                 type: Workflow.event_type(),
                 data: %{
                   action: "save_preferences",
                   preference_key: "theme",
                   value: "light"
                 },
                 correlation_id: "corr-fs-001",
                 request_id: "req-fs-001"
               },
               %{correlation_id: "corr-fs-001", request_id: "req-fs-001"}
             )

    assert route_result.service == Workflow.service()
    assert route_result.operation == Workflow.operation()
    assert route_result.outcome == "ok"
    assert route_result.payload.preference.key == "theme"
    assert route_result.payload.ui_hints.primary_notice == "Saved preference for theme"
    assert route_result.payload.ui_hints.severity == "info"
    assert route_result.payload.ui_hints.next_actions == ["continue_editing", "submit_another_change"]
    assert route_result.payload.ui_hints.focus_field == "theme"

    assert Enum.any?(route_result.events, fn event ->
             event.event_name == "runtime.first_slice.preference_saved.v1"
           end)
  end

  test "returns typed validation error when required fields are missing" do
    assert {:ok, request} =
             ServiceRequestEnvelope.new(
               Workflow.service(),
               Workflow.operation(),
               %{correlation_id: "corr-fs-002", request_id: "req-fs-002"},
               %{data: %{action: "save_preferences", preference_key: "theme"}}
             )

    assert {:error, error} = Workflow.handle_request(request)
    assert error.error_code == "first_slice.missing_required_fields"
    assert error.category == "validation"
  end

  test "returns retryable typed dependency error for retryable failure action" do
    assert {:ok, request} =
             ServiceRequestEnvelope.new(
               Workflow.service(),
               Workflow.operation(),
               %{correlation_id: "corr-fs-003", request_id: "req-fs-003"},
               %{data: %{action: "retryable_failure", preference_key: "theme", value: "dark"}}
             )

    assert {:error, error} = Workflow.handle_request(request)
    assert error.error_code == "first_slice.retryable_dependency_error"
    assert error.category == "dependency"
    assert error.retryable == true
  end
end
