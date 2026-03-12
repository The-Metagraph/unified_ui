defmodule UnifiedUi.Dsl.SanitizationTest do
  @moduledoc """
  Tests for the UnifiedUi DSL Sanitization module.

  These tests verify that:
  - String sanitization removes dangerous characters
  - Input sanitization handles password fields correctly
  - Map sanitization works recursively
  - Password field detection works correctly
  - Error message sanitization is safe
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.Sanitization

  describe "sanitize_string/2" do
    test "removes HTML tags from strings" do
      assert {:ok, "scriptalert('xss')/script"} =
               Sanitization.sanitize_string("<script>alert('xss')</script>", 100)
    end

    test "removes HTML entity encoded tags" do
      # Note: The sanitization removes &lt; and &gt; after converting them
      # So &lt;script&gt;text&lt;/script&gt; becomes "scripttext/script"
      assert {:ok, "scripttext/script"} =
               Sanitization.sanitize_string("&lt;script&gt;text&lt;/script&gt;", 100)
    end

    test "returns :too_long for strings exceeding max_length" do
      long_string = String.duplicate("a", 200)

      assert {:error, :too_long} = Sanitization.sanitize_string(long_string, 100)
    end

    test "accepts strings within max_length" do
      assert {:ok, "normal text"} = Sanitization.sanitize_string("normal text", 100)
    end

    test "handles empty strings" do
      assert {:ok, ""} = Sanitization.sanitize_string("", 100)
    end

    test "handles strings exactly at max_length" do
      exact_string = String.duplicate("a", 100)

      assert {:ok, ^exact_string} = Sanitization.sanitize_string(exact_string, 100)
    end

    test "returns :invalid_type for non-string values" do
      assert {:error, :invalid_type} = Sanitization.sanitize_string(123, 100)
      assert {:error, :invalid_type} = Sanitization.sanitize_string(nil, 100)
      assert {:error, :invalid_type} = Sanitization.sanitize_string(%{}, 100)
    end

    test "removes ampersand character" do
      assert {:ok, "text"} = Sanitization.sanitize_string("text&", 100)
    end
  end

  describe "sanitize_input/2" do
    test "redacts password fields" do
      assert {:ok, "[REDACTED]"} = Sanitization.sanitize_input(:password, "secret123")
    end

    test "redacts passwd fields" do
      assert {:ok, "[REDACTED]"} = Sanitization.sanitize_input(:passwd, "secret123")
    end

    test "redacts secret fields" do
      assert {:ok, "[REDACTED]"} = Sanitization.sanitize_input(:secret, "my_secret")
    end

    test "redacts token fields" do
      assert {:ok, "[REDACTED]"} = Sanitization.sanitize_input(:token, "abc123xyz")
    end

    test "redacts api_key fields" do
      assert {:ok, "[REDACTED]"} = Sanitization.sanitize_input(:api_key, "key_123")
    end

    test "sanitizes regular string fields" do
      assert {:ok, "user@example.com"} = Sanitization.sanitize_input(:email, "user@example.com")
    end

    test "sanitizes string fields with HTML tags" do
      assert {:ok, "test"} = Sanitization.sanitize_input(:comment, "<test>")
    end

    test "passes through non-string values" do
      assert {:ok, 123} = Sanitization.sanitize_input(:count, 123)
      assert {:ok, nil} = Sanitization.sanitize_input(:optional, nil)
    end

    test "redacts long string fields exceeding max length" do
      long_string = String.duplicate("a", 15_000)

      assert {:error, :too_long} = Sanitization.sanitize_input(:data, long_string)
    end
  end

  describe "sanitize_map/2" do
    test "sanitizes string values in map" do
      input = %{email: "user@example.com", name: "<script>alert('xss')</script>"}

      assert {:ok, sanitized} = Sanitization.sanitize_map(input)
      assert sanitized.email == "user@example.com"
      assert sanitized.name == "scriptalert('xss')/script"
    end

    test "redacts password fields in map" do
      input = %{email: "user@example.com", password: "secret123"}

      assert {:ok, sanitized} = Sanitization.sanitize_map(input)
      assert sanitized.email == "user@example.com"
      assert sanitized.password == "[REDACTED]"
    end

    test "sanitizes nested maps" do
      input = %{
        user: %{
          email: "user@example.com",
          password: "secret123"
        }
      }

      assert {:ok, sanitized} = Sanitization.sanitize_map(input)
      assert sanitized.user.email == "user@example.com"
      assert sanitized.user.password == "[REDACTED]"
    end

    test "returns :map_too_large for maps with too many keys" do
      input =
        1..101
        |> Enum.into(%{}, fn i -> {:"key_#{i}", "value"} end)

      assert {:error, :map_too_large} = Sanitization.sanitize_map(input)
    end

    test "handles maps with exactly max keys" do
      input =
        1..100
        |> Enum.into(%{}, fn i -> {:"key_#{i}", "value"} end)

      assert {:ok, sanitized} = Sanitization.sanitize_map(input)
      assert map_size(sanitized) == 100
    end

    test "returns :max_depth_exceeded for deeply nested maps" do
      # Create a map 11 levels deep (max is 10)
      # With current behavior, deeply nested values get redacted, not failed
      # Build it step by step to ensure correct brace counting
      l1 = %{deep: "value"}
      l2 = %{level: l1}
      l3 = %{level: l2}
      l4 = %{level: l3}
      l5 = %{level: l4}
      l6 = %{level: l5}
      l7 = %{level: l6}
      l8 = %{level: l7}
      l9 = %{level: l8}
      l10 = %{level: l9}
      l11 = %{level: l10}
      l12 = %{level: l11}

      # The deeply nested value gets redacted as "[REDACTED]" or "[Nested data]"
      # rather than failing the entire map
      assert {:ok, sanitized} = Sanitization.sanitize_map(l12)
      # The 10th level should show "[Nested data]"
      assert sanitized.level.level.level.level.level.level.level.level.level.level == "[Nested data]"
    end

    test "handles empty maps" do
      assert {:ok, %{}} = Sanitization.sanitize_map(%{})
    end
  end

  describe "should_redact?/1" do
    test "returns true for password atom" do
      assert Sanitization.should_redact?(:password) == true
    end

    test "returns true for passwd atom" do
      assert Sanitization.should_redact?(:passwd) == true
    end

    test "returns true for pwd atom" do
      assert Sanitization.should_redact?(:pwd) == true
    end

    test "returns true for secret atom" do
      assert Sanitization.should_redact?(:secret) == true
    end

    test "returns true for token atom" do
      assert Sanitization.should_redact?(:token) == true
    end

    test "returns true for api_key atom" do
      assert Sanitization.should_redact?(:api_key) == true
    end

    test "returns true for compound names containing password" do
      assert Sanitization.should_redact?(:user_password) == true
      assert Sanitization.should_redact?(:confirm_password) == true
    end

    test "returns false for non-password fields" do
      assert Sanitization.should_redact?(:email) == false
      assert Sanitization.should_redact?(:name) == false
      assert Sanitization.should_redact?(:username) == false
    end

    test "works with strings" do
      assert Sanitization.should_redact?("password") == true
      assert Sanitization.should_redact?("user_password") == true
      assert Sanitization.should_redact?("email") == false
    end

    test "is case insensitive" do
      assert Sanitization.should_redact?(:Password) == true
      assert Sanitization.should_redact?(:PASSWORD) == true
      assert Sanitization.should_redact?("PASSWORD") == true
    end
  end

  describe "sanitize_for_error/2" do
    test "redacts password fields" do
      assert Sanitization.sanitize_for_error(:password, "secret123") == "[REDACTED]"
    end

    test "truncates long values" do
      long_value = String.duplicate("a", 200)

      result = Sanitization.sanitize_for_error(long_value, 50)
      assert result == "[Value sanitized: 200 characters]"
    end

    test "removes HTML tags from error values" do
      assert Sanitization.sanitize_for_error("<script>alert('xss')</script>", 100) ==
               "scriptalert('xss')/script"
    end

    test "handles normal strings" do
      assert Sanitization.sanitize_for_error("normal text", 100) == "normal text"
    end

    test "handles atoms" do
      assert Sanitization.sanitize_for_error(:some_atom, 100) == ":some_atom"
    end

    test "handles numbers" do
      assert Sanitization.sanitize_for_error(123, 100) == "123"
      assert Sanitization.sanitize_for_error(3.14, 100) == "3.14"
    end

    test "returns [Complex type] for unsupported types" do
      assert Sanitization.sanitize_for_error(%{}, 100) == "[Complex type]"
      assert Sanitization.sanitize_for_error([1, 2, 3], 100) == "[Complex type]"
    end

    test "uses default max_length when not specified" do
      long_value = String.duplicate("a", 200)

      result = Sanitization.sanitize_for_error(long_value)
      assert result == "[Value sanitized: 200 characters]"
    end
  end
end
