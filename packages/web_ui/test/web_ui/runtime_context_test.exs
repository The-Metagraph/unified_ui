defmodule WebUi.RuntimeContextTest do
  use ExUnit.Case, async: true

  alias WebUi.RuntimeContext
  alias WebUi.TypedError

  test "validates required context fields" do
    context = %{
      correlation_id: "corr-301",
      request_id: "req-301",
      session_id: "session-301",
      user_id: "user-301"
    }

    assert {:ok, normalized} = RuntimeContext.validate(context)
    assert normalized.correlation_id == "corr-301"
    assert normalized.request_id == "req-301"
    assert normalized.session_id == "session-301"
    assert normalized.user_id == "user-301"
  end

  test "rejects missing required context fields" do
    assert {:error, %TypedError{} = error} = RuntimeContext.validate(%{correlation_id: "corr-301"})

    assert error.error_code == "runtime_context.missing_required_fields"
    assert :request_id in error.details[:missing_fields]
  end

  test "rejects non-map context" do
    assert {:error, %TypedError{} = error} = RuntimeContext.validate(:invalid)
    assert error.error_code == "runtime_context.invalid_shape"
  end
end
