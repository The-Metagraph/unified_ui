defmodule WebUi.Integration.Phase13OutcomeHintsTest do
  use ExUnit.Case, async: true

  alias WebUi.Channel
  alias WebUi.FirstSlice.Workflow
  alias WebUi.Ui.Message
  alias WebUi.Ui.Runtime

  @moduletag :conformance

  defp model_with_session do
    {:ok, model, _commands} =
      Runtime.init(%{
        runtime_context: %{
          correlation_id: "corr-13",
          request_id: "req-13",
          session_id: "sess-13"
        }
      })

    model
  end

  test "SCN-018 success outcomes include normalized ui_hints through channel/runtime flow" do
    {:ok, runtime_agent} = Workflow.agent()
    model = model_with_session()

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

    hint_payload = response.payload.result.payload.ui_hints

    assert hint_payload.primary_notice == "Saved preference for theme"
    assert hint_payload.severity == "info"
    assert hint_payload.next_actions == ["continue_editing", "submit_another_change"]
    assert hint_payload.focus_field == "theme"

    {updated_model, []} = Runtime.update(model, Message.websocket_recv(response.payload))

    assert updated_model.view_state.reconciliation_hints == %{
             primary_notice: "Saved preference for theme",
             severity: "info",
             next_actions: ["continue_editing", "submit_another_change"],
             focus_field: "theme"
           }

    assert hd(updated_model.view_state.notices) == "slice:ok:ui.preferences/save_preferences"
  end

  test "SCN-018 reconciliation hints apply deterministically across repeated equivalent outcomes" do
    model = model_with_session()

    outcome = %{
      result: %{
        service: "ui.preferences",
        operation: "save_preferences",
        outcome: "ok",
        payload: %{
          ui_patch: %{notice: "Preference saved"},
          ui_hints: %{
            primary_notice: "Saved preference for theme",
            severity: "info",
            next_actions: ["continue_editing", "submit_another_change"],
            focus_field: "theme"
          }
        },
        context: %{correlation_id: "corr-13", request_id: "req-13", session_id: "sess-13"}
      }
    }

    {model_a, []} = Runtime.update(model, Message.websocket_recv(outcome))
    {model_b, []} = Runtime.update(model, Message.websocket_recv(outcome))

    assert model_a.view_state.reconciliation_hints == model_b.view_state.reconciliation_hints
    assert model_a.view_state.reconciliation_hints.next_actions == ["continue_editing", "submit_another_change"]
  end

  test "SCN-018 error outcomes clear stale ui_hints while preserving typed error behavior" do
    model = model_with_session()

    {model, []} =
      Runtime.update(
        model,
        Message.websocket_recv(%{
          result: %{
            service: "ui.preferences",
            operation: "save_preferences",
            outcome: "ok",
            payload: %{
              ui_hints: %{
                primary_notice: "Saved preference for theme",
                severity: "info",
                next_actions: ["continue_editing"],
                focus_field: "theme"
              }
            },
            context: %{correlation_id: "corr-13", request_id: "req-13", session_id: "sess-13"}
          }
        })
      )

    assert model.view_state.reconciliation_hints.primary_notice == "Saved preference for theme"

    {updated_model, []} =
      Runtime.update(
        model,
        Message.websocket_recv(%{
          result: %{
            service: "ui.preferences",
            operation: "save_preferences",
            outcome: "error",
            error: %{
              error_code: "first_slice.retryable_dependency_error",
              category: "dependency",
              retryable: true,
              correlation_id: "corr-13"
            },
            context: %{correlation_id: "corr-13", request_id: "req-13", session_id: "sess-13"}
          }
        })
      )

    assert updated_model.last_error.error_code == "first_slice.retryable_dependency_error"
    assert updated_model.recovery_state.retry_pending? == true
    assert updated_model.view_state.reconciliation_hints == %{
             primary_notice: nil,
             severity: nil,
             next_actions: [],
             focus_field: nil
           }
  end
end
