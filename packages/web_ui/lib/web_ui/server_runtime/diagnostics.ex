defmodule WebUi.ServerRuntime.Diagnostics do
  @moduledoc """
  Diagnostics and validation helpers for web_ui server runtime.

  Provides validation and diagnostic functions for detecting and
  reporting runtime issues.
  """

  alias WebUi.ServerRuntime.BrowserBridge

  @type diagnostic :: %{
          type: atom(),
          severity: :info | :warning | :error,
          message: String.t(),
          details: map() | nil
        }

  @doc """
  Validates that a screen module satisfies the required contract.
  """
  @spec validate_screen_module(module()) :: [:ok | {:error, diagnostic()}]
  def validate_screen_module(screen) when is_atom(screen) do
    [
      validate_module_loaded(screen),
      validate_screen_id(screen),
      validate_mount_defaults(screen),
      validate_render_function(screen),
      validate_event_routes(screen),
      validate_handle_event(screen),
      validate_frontend_schema(screen)
    ]
    |> Enum.reject(&(&1 == :ok))
  end

  @doc """
  Validates a message envelope from the frontend.
  """
  @spec validate_envelope(map()) :: :ok | {:error, diagnostic()}
  def validate_envelope(%{type: type, payload: payload}) when is_binary(type) and is_map(payload) do
    :ok
  end

  def validate_envelope(envelope) do
    {:error,
     %{
       type: :invalid_envelope,
       severity: :error,
       message: "Message envelope must have :type (string) and :payload (map)",
       details: %{envelope: inspect(envelope)}
     }}
  end

  @doc """
  Validates browser bridge hooks.
  """
  @spec validate_hooks([atom()]) :: :ok | {:error, diagnostic()}
  def validate_hooks(hooks) when is_list(hooks) do
    unsupported = Enum.reject(hooks, &BrowserBridge.supported?/1)

    if Enum.empty?(unsupported) do
      :ok
    else
      {:error,
       %{
         type: :unsupported_hooks,
         severity: :warning,
         message: "Some browser bridge hooks are not supported",
         details: %{unsupported: unsupported}
       }}
    end
  end

  @doc """
  Validates runtime state consistency.
  """
  @spec validate_runtime_state(map()) :: [:ok | {:error, diagnostic()}]
  def validate_runtime_state(state) when is_map(state) do
    required_keys = [:screen, :assigns, :mode, :event_routes, :frontend_sync]

    missing =
      required_keys
      |> Enum.reject(&Map.has_key?(state, &1))

    if Enum.empty?(missing) do
      [:ok]
    else
      [
        {:error,
         %{
           type: :missing_state_keys,
           severity: :error,
           message: "Runtime state is missing required keys",
           details: %{missing: missing}
         }}
      ]
    end
  end

  # Private validation functions

  defp validate_module_loaded(screen) do
    if Code.ensure_loaded?(screen) do
      :ok
    else
      {:error,
       %{
         type: :module_not_loaded,
         severity: :error,
         message: "Screen module is not loaded",
         details: %{screen: inspect(screen)}
       }}
    end
  end

  defp validate_screen_id(screen) do
    if function_exported?(screen, :id, 0) do
      :ok
    else
      {:error,
       %{
         type: :missing_function,
         severity: :error,
         message: "Screen must export id/0",
         details: %{screen: inspect(screen), function: :id}
       }}
    end
  end

  defp validate_mount_defaults(screen) do
    if function_exported?(screen, :mount_defaults, 0) do
      :ok
    else
      {:error,
       %{
         type: :missing_function,
         severity: :error,
         message: "Screen must export mount_defaults/0",
         details: %{screen: inspect(screen), function: :mount_defaults}
       }}
    end
  end

  defp validate_render_function(screen) do
    if function_exported?(screen, :render, 1) do
      :ok
    else
      {:error,
       %{
         type: :missing_function,
         severity: :error,
         message: "Screen must export render/1",
         details: %{screen: inspect(screen), function: :render}
       }}
    end
  end

  defp validate_event_routes(screen) do
    if function_exported?(screen, :event_routes, 0) do
      :ok
    else
      {:error,
       %{
         type: :missing_function,
         severity: :error,
         message: "Screen must export event_routes/0",
         details: %{screen: inspect(screen), function: :event_routes}
       }}
    end
  end

  defp validate_handle_event(screen) do
    if function_exported?(screen, :handle_event, 3) do
      :ok
    else
      {:error,
       %{
         type: :missing_function,
         severity: :error,
         message: "Screen must export handle_event/3",
         details: %{screen: inspect(screen), function: :handle_event}
       }}
    end
  end

  defp validate_frontend_schema(screen) do
    if function_exported?(screen, :frontend_schema, 0) do
      :ok
    else
      {:error,
       %{
         type: :missing_function,
         severity: :error,
         message: "Screen must export frontend_schema/0",
         details: %{screen: inspect(screen), function: :frontend_schema}
       }}
    end
  end
end
