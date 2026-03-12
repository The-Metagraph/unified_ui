defmodule UnifiedUi.Adapters.SecurityTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.Security module.

  Tests security validations, sanitization, and redaction functions.
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Security

  # ============================================================================
  # Event Action Validation Tests
  # ============================================================================

  describe "validate_event_action/2" do
    test "validates mouse actions from allowlist" do
      valid_actions = [
        :click,
        :double_click,
        :right_click,
        :middle_click,
        :scroll,
        :move,
        :down,
        :up
      ]

      Enum.each(valid_actions, fn action ->
        assert Security.validate_event_action(:mouse, action) == :ok
      end)
    end

    test "rejects invalid mouse actions" do
      invalid_actions = [:malicious, :injection, "../etc/passwd", "<script>"]

      Enum.each(invalid_actions, fn action ->
        assert Security.validate_event_action(:mouse, action) == {:error, :invalid_action}
      end)
    end

    test "validates window actions from allowlist" do
      valid_actions = [
        :move,
        :resize,
        :close,
        :minimize,
        :maximize,
        :restore,
        :focus,
        :blur,
        :show,
        :hide
      ]

      Enum.each(valid_actions, fn action ->
        assert Security.validate_event_action(:window, action) == :ok
      end)
    end

    test "rejects invalid window actions" do
      assert Security.validate_event_action(:window, :format_c) == {:error, :invalid_action}
      assert Security.validate_event_action(:window, "<script>") == {:error, :invalid_action}
    end

    test "allows all click, change, submit actions" do
      assert Security.validate_event_action(:click, :any_action) == :ok
      assert Security.validate_event_action(:change, :any_action) == :ok
      assert Security.validate_event_action(:submit, :any_action) == :ok
    end

    test "allows valid key actions" do
      assert Security.validate_event_action(:key, :press) == :ok
      assert Security.validate_event_action(:key, :release) == :ok
      assert Security.validate_event_action(:key, :down) == :ok
      assert Security.validate_event_action(:key, :up) == :ok
    end

    test "rejects invalid key actions" do
      assert Security.validate_event_action(:key, :malicious) == {:error, :invalid_action}
    end

    test "allows valid focus actions" do
      assert Security.validate_event_action(:focus, :focus) == :ok
      assert Security.validate_event_action(:focus, :blur) == :ok
    end

    test "rejects invalid focus actions" do
      assert Security.validate_event_action(:focus, :steal) == {:error, :invalid_action}
    end
  end

  # ============================================================================
  # Event Data Sanitization Tests
  # ============================================================================

  describe "sanitize_event_data/1" do
    test "removes HTML tags from string values" do
      data = %{value: "<script>alert('xss')</script>", widget_id: :input}
      assert {:ok, sanitized} = Security.sanitize_event_data(data)
      assert sanitized.value != data.value
      assert sanitized.value =~ "scriptalert"
      refute sanitized.value =~ "<"
    end

    test "preserves non-string values" do
      data = %{widget_id: :input, count: 42, active: true}
      assert {:ok, sanitized} = Security.sanitize_event_data(data)
      assert sanitized.widget_id == :input
      assert sanitized.count == 42
      assert sanitized.active == true
    end

    test "sanitizes nested maps" do
      data = %{nested: %{value: "<script>attack</script>"}}
      assert {:ok, sanitized} = Security.sanitize_event_data(data)
      refute sanitized.nested.value =~ "<"
    end

    test "handles empty maps" do
      assert {:ok, %{}} = Security.sanitize_event_data(%{})
    end

    test "handles lists as values" do
      data = %{items: ["a", "b", "c"]}
      assert {:ok, sanitized} = Security.sanitize_event_data(data)
      assert sanitized.items == ["a", "b", "c"]
    end

    test "handles nil values" do
      data = %{value: nil}
      assert {:ok, sanitized} = Security.sanitize_event_data(data)
      assert sanitized.value == nil
    end
  end

  # ============================================================================
  # Credential Redaction Tests
  # ============================================================================

  describe "redact_sensitive_fields/1" do
    test "redacts password field" do
      data = %{password: "secret123", username: "user"}
      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.password == "[REDACTED]"
      assert redacted.username == "user"
    end

    test "redacts passwd field" do
      data = %{passwd: "secret"}
      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.passwd == "[REDACTED]"
    end

    test "redacts pwd field" do
      data = %{pwd: "secret"}
      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.pwd == "[REDACTED]"
    end

    test "redacts secret field" do
      data = %{secret: "my_secret"}
      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.secret == "[REDACTED]"
    end

    test "redacts token field" do
      data = %{token: "abc123xyz"}
      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.token == "[REDACTED]"
    end

    test "redacts api_key field" do
      data = %{api_key: "key_123"}
      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.api_key == "[REDACTED]"
    end

    test "redacts apikey field" do
      data = %{apikey: "key_456"}
      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.apikey == "[REDACTED]"
    end

    test "redacts passphrase field" do
      data = %{passphrase: "long_secret_passphrase"}
      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.passphrase == "[REDACTED]"
    end

    test "does not redact regular fields" do
      data = %{username: "user", email: "user@example.com", age: 30}
      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.username == "user"
      assert redacted.email == "user@example.com"
      assert redacted.age == 30
    end

    test "redacts multiple sensitive fields in same map" do
      data = %{
        username: "user",
        password: "secret",
        token: "abc",
        api_key: "xyz",
        normal_field: "value"
      }

      assert {:ok, redacted} = Security.redact_sensitive_fields(data)
      assert redacted.username == "user"
      assert redacted.password == "[REDACTED]"
      assert redacted.token == "[REDACTED]"
      assert redacted.api_key == "[REDACTED]"
      assert redacted.normal_field == "value"
    end

    test "handles empty map" do
      assert {:ok, %{}} = Security.redact_sensitive_fields(%{})
    end
  end

  # ============================================================================
  # Payload Validation Tests
  # ============================================================================

  describe "validate_signal_payload/1" do
    test "accepts valid small payloads" do
      assert :ok = Security.validate_signal_payload(%{widget_id: :btn})
      assert :ok = Security.validate_signal_payload(%{x: 1, y: 2})
      assert :ok = Security.validate_signal_payload(%{value: "test"})
    end

    test "rejects payloads with strings that are too long" do
      long_string = String.duplicate("a", 2000)
      assert {:error, :string_too_long} = Security.validate_signal_payload(%{data: long_string})
    end

    test "rejects payloads that are too large" do
      large_map = Map.new(1..1000, fn i -> {:"key#{i}", "value"} end)
      assert {:error, :payload_too_large} = Security.validate_signal_payload(large_map)
    end

    test "rejects payloads that are too deep" do
      deep_map = create_deep_map(20)
      assert {:error, :payload_too_deep} = Security.validate_signal_payload(deep_map)
    end

    defp create_deep_map(depth) when depth <= 0, do: %{value: :end}
    defp create_deep_map(depth), do: %{nested: create_deep_map(depth - 1)}
  end

  # ============================================================================
  # Full Security Pipeline Tests
  # ============================================================================

  describe "secure_event_data/1" do
    test "applies full security pipeline to event data" do
      data = %{
        password: "secret123",
        value: "<script>alert('xss')</script>",
        username: "user",
        widget_id: :input
      }

      assert {:ok, secured} = Security.secure_event_data(data)

      # Password should be redacted
      assert secured.password == "[REDACTED]"

      # Value should be sanitized
      refute secured.value =~ "<"
      refute secured.value =~ ">"

      # Normal fields should be preserved
      assert secured.username == "user"
      assert secured.widget_id == :input
    end

    test "returns error for invalid payload" do
      long_string = String.duplicate("a", 20_000)
      assert {:error, _} = Security.secure_event_data(%{data: long_string})
    end

    test "handles empty event data" do
      assert {:ok, %{}} = Security.secure_event_data(%{})
    end
  end
end
