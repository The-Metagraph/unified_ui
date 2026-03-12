defmodule WebUi.Integration.Phase10FirstSliceReleaseReadinessTest do
  use ExUnit.Case, async: false

  alias WebUi.Channel
  alias WebUi.FirstSlice.Workflow
  alias WebUi.Release.Readiness
  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @root Path.expand("../../..", __DIR__)

  test "SCN-005 canonical success flow reaches runtime and reconciles UI" do
    {:ok, runtime_agent} = Workflow.agent()

    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-10-001",
          request_id: "req-10-001",
          session_id: "sess-10"
        }
      })

    {model, [command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: Workflow.event_type(),
          widget_id: "prefs_form",
          widget_kind: "form",
          data: %{action: "save_preferences", preference_key: "theme", value: "dark"}
        })
      )

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               command.event_name,
               command.payload,
               agent: runtime_agent
             )

    assert response.event_name == "runtime.event.recv.v1"

    {updated_model, []} = Runtime.update(model, Message.websocket_recv(response.payload))

    assert updated_model.connection_state == :connected
    assert updated_model.slice_state.status == :completed
    assert updated_model.slice_state.last_outcome == :ok
    assert hd(updated_model.view_state.notices) == "slice:ok:ui.preferences/save_preferences"
  end

  test "SCN-005 runtime failure returns typed errors and deterministic UI state" do
    {:ok, runtime_agent} = Workflow.agent()

    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-10-002",
          request_id: "req-10-002",
          session_id: "sess-10"
        }
      })

    {model, [command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: Workflow.event_type(),
          widget_id: "prefs_form",
          widget_kind: "form",
          data: %{action: "retryable_failure", preference_key: "theme", value: "dark"}
        })
      )

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               command.event_name,
               command.payload,
               agent: runtime_agent
             )

    {updated_model, []} = Runtime.update(model, Message.websocket_recv(response.payload))

    assert updated_model.connection_state == :error
    assert updated_model.last_error.error_code == "first_slice.retryable_dependency_error"
    assert updated_model.view_state.ui_error.code == "first_slice.retryable_dependency_error"
    assert updated_model.recovery_state.retry_pending? == true
    assert updated_model.slice_state.status == :failed
  end

  test "SCN-016 reconnect and retry preserve request continuity" do
    {:ok, runtime_agent} = Workflow.agent()

    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-10-003",
          request_id: "req-10-003",
          session_id: "sess-10"
        }
      })

    {model, [command]} =
      Runtime.update(
        model,
        Message.widget_event(%{
          type: Workflow.event_type(),
          widget_id: "prefs_form",
          widget_kind: "form",
          data: %{action: "retryable_failure", preference_key: "theme", value: "dark"}
        })
      )

    assert {:ok, response} =
             Channel.handle_client_message(
               "webui:runtime:v1",
               command.event_name,
               command.payload,
               agent: runtime_agent
             )

    {model, []} = Runtime.update(model, Message.websocket_recv(response.payload))

    {model, [reconnect_command]} =
      Runtime.update(model, Message.websocket_disconnected(%{reason: "socket_lost"}))

    {updated_model, [retry_command]} = Runtime.update(model, Message.retry_requested(%{}))

    assert reconnect_command.kind == :ws_join
    assert reconnect_command.topic == "webui:runtime:session:sess-10:v1"
    assert retry_command == command
    assert retry_command.payload.event["correlation_id"] == "corr-10-003"
    assert retry_command.payload.event["request_id"] == "req-10-003"
    assert updated_model.slice_state.status == :retrying
    assert updated_model.slice_state.attempts >= 2
  end

  test "SCN-019 release gate fails when governance or conformance is invalid" do
    unknown_id = scenario_id(999)

    with_temp_worktree(fn worktree_root ->
      matrix = Path.join(worktree_root, "specs/conformance/spec_conformance_matrix.md")

      File.write!(
        matrix,
        File.read!(matrix)
        |> String.replace(
          "| `specs/operations/rfc_intake_governance.md` | `AC-*` | `REQ-CP-*`, `REQ-OBS-*` | `SCN-001`, `SCN-006` |",
          "| `specs/operations/rfc_intake_governance.md` | `AC-*` | `REQ-CP-*`, `REQ-OBS-*` | `SCN-001`, `SCN-006`, `#{unknown_id}` |",
          global: false
        )
      )

      {output, status} = run_release_gate(worktree_root, ["--report-only"])

      assert status == 1
      assert output =~ unknown_id
      assert output =~ "Governance validation failed"
    end)
  end

  test "SCN-019 release gate passes when required checks are green" do
    {output, status} = run_release_gate(@root, ["--report-only"])

    assert status == 0
    assert output =~ "Release readiness gate passed."
  end

  test "SCN-019 rollback decision criteria map to observable runtime signals" do
    assert {:go, %{reasons: []}} =
             Readiness.rollback_decision(%{
               decode_error_ratio: 1.1,
               encode_error_ratio: 1.0,
               service_latency_p95_ratio: 1.4,
               retryable_error_budget_ratio: 0.8,
               joinability_failures: 0
             })

    assert {:rollback, %{reasons: reasons}} =
             Readiness.rollback_decision(%{
               decode_error_ratio: 2.2,
               encode_error_ratio: 2.1,
               service_latency_p95_ratio: 2.3,
               retryable_error_budget_ratio: 1.3,
               joinability_failures: 2
             })

    assert Enum.any?(reasons, &String.contains?(&1, "decode_error_ratio"))
    assert Enum.any?(reasons, &String.contains?(&1, "joinability_failures"))
  end

  defp run_release_gate(root, args) when is_binary(root) and is_list(args) do
    System.cmd(
      "bash",
      ["./scripts/run_release_readiness.sh" | args],
      cd: root,
      env: [{"MIX_ENV", "test"}],
      stderr_to_stdout: true
    )
  end

  defp with_temp_worktree(test_fun) do
    unique = System.unique_integer([:positive])
    worktree_path = Path.join(System.tmp_dir!(), "web_ui_phase10_worktree_#{unique}")

    {_, add_status} =
      System.cmd(
        "git",
        ["worktree", "add", "--detach", worktree_path, "HEAD"],
        cd: @root,
        stderr_to_stdout: true
      )

    assert add_status == 0

    on_exit(fn ->
      System.cmd(
        "git",
        ["worktree", "remove", "--force", worktree_path],
        cd: @root,
        stderr_to_stdout: true
      )
    end)

    test_fun.(worktree_path)
  end

  defp scenario_id(number) when is_integer(number) and number > 0 do
    "SCN-" <> (number |> Integer.to_string() |> String.pad_leading(3, "0"))
  end
end
