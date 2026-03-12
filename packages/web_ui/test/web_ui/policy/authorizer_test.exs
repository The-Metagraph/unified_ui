defmodule WebUi.Policy.AuthorizerTest do
  use ExUnit.Case, async: true

  alias WebUi.Policy.Authorizer
  alias WebUi.TypedError

  defp event_payload(overrides \\ %{}) do
    Map.merge(
      %{
        type: "unified.button.clicked",
        widget_id: "save_button",
        widget_kind: "button",
        data: %{action: "save"}
      },
      overrides
    )
  end

  defp context(overrides \\ %{}) do
    Map.merge(
      %{
        correlation_id: "corr-pol-001",
        request_id: "req-pol-001"
      },
      overrides
    )
  end

  test "allows widget events when no policy is configured" do
    assert :ok == Authorizer.authorize_widget_event(event_payload(), context())
  end

  test "denies blocked event types with typed authorization errors" do
    runtime_context =
      context(%{
        policy: %{
          deny_event_types: ["unified.button.clicked"]
        }
      })

    assert {:error, %TypedError{} = error} =
             Authorizer.authorize_widget_event(event_payload(), runtime_context)

    assert error.error_code == "policy.authorization.event_type_denied"
    assert error.category == "authorization"
  end

  test "denies blocked widget ids with typed authorization errors" do
    runtime_context =
      context(%{
        policy: %{
          deny_widget_ids: ["save_button"]
        }
      })

    assert {:error, %TypedError{} = error} =
             Authorizer.authorize_widget_event(event_payload(), runtime_context)

    assert error.error_code == "policy.authorization.widget_id_denied"
  end

  test "denies when event is not present in explicit allowlist" do
    runtime_context =
      context(%{
        policy: %{
          allow_event_types: ["unified.form.submitted"]
        }
      })

    assert {:error, %TypedError{} = error} =
             Authorizer.authorize_widget_event(event_payload(), runtime_context)

    assert error.error_code == "policy.authorization.event_type_not_allowed"
  end

  test "requires user_id for configured protected event types" do
    runtime_context =
      context(%{
        policy: %{
          require_user_for_event_types: ["unified.button.clicked"]
        }
      })

    assert {:error, %TypedError{} = error} =
             Authorizer.authorize_widget_event(event_payload(), runtime_context)

    assert error.error_code == "policy.authorization.user_required"

    assert :ok ==
             Authorizer.authorize_widget_event(
               event_payload(),
               Map.put(runtime_context, :user_id, "user-42")
             )
  end

  test "fails closed for malformed policy documents" do
    assert {:error, %TypedError{} = error} =
             Authorizer.authorize_widget_event(
               event_payload(),
               context(%{policy: "invalid"})
             )

    assert error.error_code == "policy.authorization.invalid_policy"
  end
end
