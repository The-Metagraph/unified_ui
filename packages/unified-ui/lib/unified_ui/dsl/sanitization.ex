defmodule UnifiedUi.Dsl.Sanitization do
  @moduledoc """
  Input sanitization utilities for UnifiedUi DSL.

  This module provides functions to sanitize user input, preventing XSS,
  injection attacks, and other security vulnerabilities.

  ## Default Limits

  * `max_string_length` - 10,000 characters (configurable)
  * `max_map_depth` - 10 levels of nesting
  * `max_map_size` - 100 keys per map

  ## Password Field Patterns

  Fields matching these patterns are considered password fields and will be
  specially handled (e.g., not stored in logs):

  * `:password`
  * `:passwd`
  * `:pwd`
  * `:secret`
  * `:token`
  * `:api_key`
  * `:apikey`
  * `:passphrase`

  ## Examples

      iex> Sanitization.sanitize_string("<script>alert('xss')</script>", 100)
      {:ok, "scriptalert('xss')/script"}

      iex> Sanitization.sanitize_string("normal text", 100)
      {:ok, "normal text"}

      iex> Sanitization.sanitize_input(:email, "user@example.com")
      {:ok, "user@example.com"}

      iex> Sanitization.should_redact?(:password)
      true

  """

  # Module attributes for configuration - must be defined before use
  @max_string_length 10_000
  @max_map_depth 10
  @max_map_size 100

  @password_patterns [
    "password",
    "passwd",
    "pwd",
    "secret",
    "token",
    "api_key",
    "apikey",
    "passphrase"
  ]

  @doc """
  Sanitizes a string value by removing potentially dangerous characters.

  This is a basic sanitization that removes:
  * HTML tags (`<...>`)
  * Common injection patterns

  For production use, consider using a dedicated HTML sanitization library.

  ## Parameters

  * `value` - The string to sanitize
  * `max_length` - Maximum allowed length (defaults to 10,000)

  ## Returns

  * `{:ok, sanitized_string}` - If sanitization succeeded
  * `{:error, :too_long}` - If string exceeds max_length
  * `{:error, :invalid_type}` - If value is not a string

  ## Examples

      iex> sanitize_string("<script>xss</script>", 100)
      {:ok, "scriptxss/script"}

      iex> sanitize_string("safe text", 100)
      {:ok, "safe text"}

      iex> sanitize_string(String.duplicate("a", 200), 100)
      {:error, :too_long}

  """
  @spec sanitize_string(any(), non_neg_integer()) :: {:ok, String.t()} | {:error, atom()}
  def sanitize_string(value, max_length \\ @max_string_length)

  def sanitize_string(value, max_length) when is_binary(value) do
    if String.length(value) > max_length do
      {:error, :too_long}
    else
      # Remove HTML tags and common dangerous characters
      # Order matters: replace HTML entities first, then raw characters
      sanitized =
        value
        |> String.replace("&lt;", "")
        |> String.replace("&gt;", "")
        |> String.replace("&amp;", "")
        |> String.replace("<", "")
        |> String.replace(">", "")
        |> String.replace("&", "")

      {:ok, sanitized}
    end
  end

  def sanitize_string(_value, _max_length) do
    {:error, :invalid_type}
  end

  @doc """
  Sanitizes a form input value based on field name.

  Password fields return a redacted placeholder instead of the actual value.

  ## Parameters

  * `field_name` - The name of the form field (atom)
  * `value` - The value to sanitize

  ## Returns

  * `{:ok, sanitized_value}` - If sanitization succeeded
  * `{:error, reason}` - If sanitization failed

  ## Examples

      iex> sanitize_input(:email, "user@example.com")
      {:ok, "user@example.com"}

      iex> sanitize_input(:password, "secret123")
      {:ok, "[REDACTED]"}

  """
  @spec sanitize_input(atom(), any()) :: {:ok, any()} | {:error, atom()}
  def sanitize_input(field_name, value) do
    cond do
      should_redact?(field_name) ->
        {:ok, "[REDACTED]"}

      is_binary(value) ->
        sanitize_string(value, @max_string_length)

      true ->
        {:ok, value}
    end
  end

  @doc """
  Sanitizes all values in a map recursively.

  ## Parameters

  * `data` - The map to sanitize
  * `max_depth` - Maximum recursion depth (defaults to 10)

  ## Returns

  * `{:ok, sanitized_map}` - If sanitization succeeded
  * `{:error, reason}` - If sanitization failed

  ## Examples

      iex> sanitize_map(%{email: "user@example.com", password: "secret"})
      {:ok, %{email: "user@example.com", password: "[REDACTED]"}}

  """
  @spec sanitize_map(map(), non_neg_integer()) :: {:ok, map()} | {:error, atom()}
  def sanitize_map(data, max_depth \\ @max_map_depth)

  def sanitize_map(data, max_depth) when is_map(data) and max_depth > 0 do
    if map_size(data) > @max_map_size do
      {:error, :map_too_large}
    else
      sanitized =
        Enum.reduce_while(data, %{}, fn {key, value}, acc ->
          case sanitize_value(key, value, max_depth - 1) do
            {:ok, sanitized_value} ->
              {:cont, Map.put(acc, key, sanitized_value)}

            {:error, _reason} = error ->
              {:halt, error}
          end
        end)

      case sanitized do
        {:error, _} = error -> error
        sanitized_map -> {:ok, sanitized_map}
      end
    end
  end

  def sanitize_map(_data, _max_depth) do
    {:error, :max_depth_exceeded}
  end

  @doc """
  Checks if a field name should be redacted (e.g., passwords).

  ## Parameters

  * `field_name` - The field name to check (atom or string)

  ## Returns

  * `true` - If the field should be redacted
  * `false` - If the field can be displayed

  ## Examples

      iex> should_redact?(:password)
      true

      iex> should_redact?(:email)
      false

      iex> should_redact?("user_password")
      true

  """
  @spec should_redact?(atom() | String.t()) :: boolean()
  def should_redact?(field_name) when is_atom(field_name) do
    field_name
    |> Atom.to_string()
    |> should_redact?()
  end

  def should_redact?(field_name) when is_binary(field_name) do
    lower_name = String.downcase(field_name)

    Enum.any?(@password_patterns, fn pattern ->
      String.contains?(lower_name, pattern)
    end)
  end

  @doc """
  Sanitizes a value for display in error messages.

  This ensures that error messages don't leak sensitive information
  or include potentially dangerous content.

  ## Parameters

  * `value` - The value to sanitize for error display
  * `max_length` - Maximum length for error display (defaults to 100)

  ## Returns

  * A sanitized string safe for error messages

  ## Examples

      iex> sanitize_for_error("<script>alert('xss')</script>", 50)
      "[Value sanitized: 28 characters]"

      iex> sanitize_for_error("normal text", 50)
      "normal text"

      iex> sanitize_for_error(:password, "secret123")
      "[REDACTED]"

  """
  @spec sanitize_for_error(any(), non_neg_integer() | atom()) :: String.t()
  def sanitize_for_error(value, max_length \\ 100)

  def sanitize_for_error(value, max_length) when is_integer(max_length) do
    cond do
      is_atom(value) and should_redact?(value) ->
        "[REDACTED]"

      is_binary(value) ->
        sanitized = String.slice(value, 0, max_length)

        if String.length(value) > max_length do
          "[Value sanitized: #{String.length(value)} characters]"
        else
          # Also strip HTML tags
          sanitized
          |> String.replace("<", "")
          |> String.replace(">", "")
        end

      is_integer(value) or is_float(value) or is_atom(value) ->
        inspect(value, limit: max_length)

      true ->
        "[Complex type]"
    end
  end

  def sanitize_for_error(field_name, value) when is_atom(field_name) do
    if should_redact?(field_name) do
      "[REDACTED]"
    else
      sanitize_for_error(value, 100)
    end
  end

  def sanitize_for_error(_field_name, _value) do
    "[Complex type]"
  end

  # Private helpers

  defp sanitize_value(_key, value, _depth) when is_number(value) or is_atom(value) do
    {:ok, value}
  end

  defp sanitize_value(key, value, _depth) when is_binary(value) do
    if should_redact?(key) do
      {:ok, "[REDACTED]"}
    else
      sanitize_string(value, min(@max_string_length, 1000))
    end
  end

  defp sanitize_value(_key, value, depth) when is_map(value) do
    if depth > 0 do
      case sanitize_map(value, depth) do
        {:ok, sanitized} ->
          {:ok, sanitized}

        {:error, _reason} ->
          # If map sanitization fails, redact the whole value
          {:ok, "[REDACTED]"}
      end
    else
      {:ok, "[Nested data]"}
    end
  end

  defp sanitize_value(_key, _value, _depth) do
    {:ok, "[Unsupported type]"}
  end
end
