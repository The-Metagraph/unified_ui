defmodule WebUi.Scope.ResolverTest do
  use ExUnit.Case, async: true

  alias WebUi.Scope.Resolver
  alias WebUi.TypedError

  defp payload(overrides \\ %{}) do
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

  defp context(overrides) when is_map(overrides) do
    Map.merge(
      %{
        correlation_id: "corr-scope-001",
        request_id: "req-scope-001",
        session_id: "sess-scope-001"
      },
      overrides
    )
  end

  test "prefers event-data scope over context/session/default scope fallbacks" do
    assert {:ok, scope} =
             Resolver.resolve_widget_scope(
               payload(%{
                 data: %{action: "save", scope_id: "workspace-alpha", scope_type: "workspace"}
               }),
               context(%{scope_id: "context-scope"})
             )

    assert scope == %{
             scope_id: "workspace-alpha",
             scope_type: "workspace",
             scope_source: "event_data"
           }
  end

  test "falls back from context scope to session scope and then global deterministically" do
    assert {:ok, context_scope} =
             Resolver.resolve_widget_scope(payload(), context(%{scope_id: "tenant-42"}))

    assert context_scope.scope_source == "runtime_context"
    assert context_scope.scope_id == "tenant-42"

    assert {:ok, session_scope} =
             Resolver.resolve_widget_scope(
               payload(),
               %{correlation_id: "corr-2", request_id: "req-2", session_id: "sess-2"}
             )

    assert session_scope.scope_source == "session"
    assert session_scope.scope_id == "sess-2"

    assert {:ok, global_scope} =
             Resolver.resolve_widget_scope(
               payload(),
               %{correlation_id: "corr-3", request_id: "req-3"}
             )

    assert global_scope.scope_source == "default"
    assert global_scope.scope_id == "global"
  end

  test "denies scopes by allow and deny policies with typed authorization errors" do
    context_with_allow =
      context(%{
        scope_policy: %{
          allow_scope_ids: ["workspace-1"]
        }
      })

    assert {:error, %TypedError{} = not_allowed_error} =
             Resolver.resolve_widget_scope(
               payload(%{data: %{scope_id: "workspace-2"}}),
               context_with_allow
             )

    assert not_allowed_error.error_code == "scope.resolution.scope_not_allowed"
    assert not_allowed_error.category == "authorization"

    context_with_deny =
      context(%{
        scope_policy: %{
          deny_scope_ids: ["workspace-2"]
        }
      })

    assert {:error, %TypedError{} = denied_error} =
             Resolver.resolve_widget_scope(
               payload(%{data: %{scope_id: "workspace-2"}}),
               context_with_deny
             )

    assert denied_error.error_code == "scope.resolution.scope_denied"
  end

  test "requires explicit scope for configured event types and fails closed on invalid policy shape" do
    context_require_scope =
      context(%{
        session_id: nil,
        scope_policy: %{require_scope_for_event_types: ["unified.button.clicked"]}
      })

    assert {:error, %TypedError{} = required_error} =
             Resolver.resolve_widget_scope(payload(), context_require_scope)

    assert required_error.error_code == "scope.resolution.scope_required"

    assert {:error, %TypedError{} = invalid_policy_error} =
             Resolver.resolve_widget_scope(payload(), context(%{scope_policy: "invalid"}))

    assert invalid_policy_error.error_code == "scope.resolution.invalid_scope_policy"
  end

  test "attach_scope_metadata injects canonical scope fields into event data" do
    data = %{"action" => "save"}
    scope = %{scope_id: "workspace-1", scope_type: "workspace", scope_source: "event_data"}

    assert Resolver.attach_scope_metadata(data, scope) == %{
             "action" => "save",
             "scope_id" => "workspace-1",
             "scope_type" => "workspace",
             "scope_source" => "event_data"
           }
  end
end
