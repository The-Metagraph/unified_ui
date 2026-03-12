defmodule UnifiedUi.Adapters.Security do
  @moduledoc """
  Centralized security utilities for UnifiedUi renderers.

  This module provides security validation and sanitization for renderer events,
  preventing common vulnerabilities such as signal injection, payload flooding,
  and credential leakage.

  ## Security Layers

  1. **Event Action Validation** - Allowlist-based validation for event actions
  2. **Payload Validation** - Size, depth, and string length limits
  3. **Input Sanitization** - Remove dangerous characters from user input
  4. **Credential Redaction** - Hide sensitive fields in signals

  ## Examples

      # Validate an event action before using it
      case validate_event_action(:mouse, :click) do
        :ok -> :action_is_valid
        {:error, _} -> :action_is_invalid
      end

      # Sanitize event data
      {:ok, clean_data} = sanitize_event_data(%{value: "<script>...</script>"})

      # Redact sensitive fields
      {:ok, redacted_data} = redact_sensitive_fields(%{password: "secret", username: "user"})
      # => %{password: "[REDACTED]", username: "user"}

  """

  alias UnifiedUi.Dsl.{SignalHelpers, Sanitization}

  # Allowlists for event actions to prevent signal injection

  @mouse_actions [
    :click,
    :double_click,
    :right_click,
    :middle_click,
    :scroll,
    :move,
    :down,
    :up
  ]

  @window_actions [
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

  @key_actions [
    :press,
    :release,
    :down,
    :up
  ]

  @focus_actions [
    :focus,
    :blur
  ]

  @doc """
  Validates an event action against an allowlist.

  Prevents signal injection by ensuring only known actions are allowed
  in dynamic signal type construction.

  ## Returns

  * `:ok` - Action is valid
  * `{:error, :invalid_action}` - Action is not in allowlist

  ## Examples

      iex> validate_event_action(:mouse, :click)
      :ok

      iex> validate_event_action(:mouse, :malicious)
      {:error, :invalid_action}

      iex> validate_event_action(:window, :resize)
      :ok

  """
  @spec validate_event_action(atom(), atom()) :: :ok | {:error, :invalid_action}
  def validate_event_action(:mouse, action) when action in @mouse_actions, do: :ok
  def validate_event_action(:window, action) when action in @window_actions, do: :ok
  def validate_event_action(:key, action) when action in @key_actions, do: :ok
  def validate_event_action(:focus, action) when action in @focus_actions, do: :ok
  def validate_event_action(:click, _action), do: :ok
  def validate_event_action(:change, _action), do: :ok
  def validate_event_action(:submit, _action), do: :ok
  def validate_event_action(_event_type, _action), do: {:error, :invalid_action}

  @doc """
  Sanitizes event data by cleaning user input.

  Applies sanitization to all string values in the event data map,
  removing potentially dangerous characters while preserving valid content.

  ## Returns

  * `{:ok, sanitized_data}` - Data sanitized successfully
  * `{:error, :sanitization_failed}` - Sanitization failed

  ## Examples

      iex> sanitize_event_data(%{value: "<script>alert('xss')</script>", widget_id: :input})
      {:ok, %{value: "scriptalert('xss')/script", widget_id: :input}}

  """
  @spec sanitize_event_data(map()) :: {:ok, map()} | {:error, atom()}
  def sanitize_event_data(data) when is_map(data) do
    sanitized =
      Enum.reduce_while(data, %{}, fn {key, value}, acc ->
        case sanitize_value(key, value) do
          {:ok, clean_value} -> {:cont, Map.put(acc, key, clean_value)}
          {:error, _} = error -> {:halt, error}
        end
      end)

    case sanitized do
      {:error, _} = error -> error
      clean_data -> {:ok, clean_data}
    end
  end

  @doc """
  Redacts sensitive field values from event data.

  Fields matching password patterns are replaced with "[REDACTED]"
  to prevent credential leakage in logs and signals.

  ## Returns

  * `{:ok, redacted_data}` - Data with sensitive fields redacted

  ## Examples

      iex> redact_sensitive_fields(%{password: "secret", username: "user"})
      {:ok, %{password: "[REDACTED]", username: "user"}}

      iex> redact_sensitive_fields(%{api_key: "abc123", token: "xyz789"})
      {:ok, %{api_key: "[REDACTED]", token: "[REDACTED]"}}

  """
  @spec redact_sensitive_fields(map()) :: {:ok, map()}
  def redact_sensitive_fields(data) when is_map(data) do
    redacted =
      Enum.map(data, fn {key, value} ->
        if Sanitization.should_redact?(key) do
          {key, "[REDACTED]"}
        else
          {key, value}
        end
      end)
      |> Enum.into(%{})

    {:ok, redacted}
  end

  @doc """
  Validates a signal payload to prevent DoS attacks.

  Wraps `SignalHelpers.validate_payload/1` for renderer use.

  ## Returns

  * `:ok` - Payload is valid
  * `{:error, reason}` - Payload validation failed

  ## Examples

      iex> validate_signal_payload(%{widget_id: :btn})
      :ok

      iex> validate_signal_payload(%{data: String.duplicate("a", 20000)})
      {:error, :payload_too_large}

  """
  @spec validate_signal_payload(map()) :: :ok | {:error, atom()}
  def validate_signal_payload(data) when is_map(data) do
    SignalHelpers.validate_payload(data)
  end

  @doc """
  Applies full security pipeline to event data.

  In order:
  1. Validates payload size
  2. Sanitizes string values
  3. Redacts sensitive fields

  ## Returns

  * `{:ok, secure_data}` - Data is valid and secured
  * `{:error, reason}` - Security check failed

  ## Examples

      iex> secure_event_data(%{password: "secret", value: "safe text"})
      {:ok, %{password: "[REDACTED]", value: "safe text"}}

  """
  @spec secure_event_data(map()) :: {:ok, map()} | {:error, atom()}
  def secure_event_data(data) when is_map(data) do
    with :ok <- validate_signal_payload(data),
         {:ok, sanitized} <- sanitize_event_data(data) do
      redact_sensitive_fields(sanitized)
    end
  end

  # Private helpers

  defp sanitize_value(_key, value) when is_binary(value) do
    Sanitization.sanitize_string(value)
  end

  defp sanitize_value(_key, value) when is_atom(value), do: {:ok, value}
  defp sanitize_value(_key, value) when is_number(value), do: {:ok, value}
  defp sanitize_value(_key, value) when is_boolean(value), do: {:ok, value}
  defp sanitize_value(_key, value) when is_list(value), do: {:ok, value}

  # For nested data structures, recursively sanitize
  defp sanitize_value(_key, value) when is_map(value) do
    # Recursively sanitize nested maps, going deeper
    Enum.reduce_while(value, {:ok, %{}}, fn {k, v}, {:ok, acc} ->
      case sanitize_value(k, v) do
        {:ok, clean_v} -> {:cont, {:ok, Map.put(acc, k, clean_v)}}
        error -> {:halt, error}
      end
    end)
  end

  defp sanitize_value(_key, _value), do: {:ok, nil}
end
