defmodule WebUi.ServerRuntime.Error do
  @moduledoc """
  Deterministic runtime error contract for `web_ui` server runtime.
  """

  @enforce_keys [:reason, :message]
  defexception [:reason, :message, :details]

  @type t :: %__MODULE__{
          reason: atom(),
          message: String.t(),
          details: map() | nil
        }

  @spec invalid_screen_module(module()) :: t()
  def invalid_screen_module(screen) do
    %__MODULE__{
      reason: :invalid_screen_module,
      message: "screen module does not satisfy the WebUi.ServerRuntime.Screen contract",
      details: %{screen: inspect(screen)}
    }
  end

  @spec invalid_mount_defaults(module()) :: t()
  def invalid_mount_defaults(screen) do
    %__MODULE__{
      reason: :invalid_mount_defaults,
      message: "screen mount defaults must be a map",
      details: %{screen: inspect(screen)}
    }
  end

  @spec invalid_event_route(module(), String.t()) :: t()
  def invalid_event_route(screen, event) do
    %__MODULE__{
      reason: :invalid_event_route,
      message: "event is not registered for the screen",
      details: %{screen: inspect(screen), event: event}
    }
  end

  @spec invalid_event_result(module(), atom(), term()) :: t()
  def invalid_event_result(screen, route, result) do
    %__MODULE__{
      reason: :invalid_event_result,
      message: "screen event handlers must return {:ok, map()} or {:error, reason}",
      details: %{screen: inspect(screen), route: route, result: inspect(result)}
    }
  end

  @spec invalid_frontend_schema(module()) :: t()
  def invalid_frontend_schema(screen) do
    %__MODULE__{
      reason: :invalid_frontend_schema,
      message: "frontend_schema must return a valid schema map",
      details: %{screen: inspect(screen)}
    }
  end

  @spec hydration_failed(module(), term()) :: t()
  def hydration_failed(screen, reason) do
    %__MODULE__{
      reason: :hydration_failed,
      message: "frontend hydration failed",
      details: %{screen: inspect(screen), reason: inspect(reason)}
    }
  end

  @spec sync_mismatch(module(), String.t(), term(), term()) :: t()
  def sync_mismatch(screen, field, expected, actual) do
    %__MODULE__{
      reason: :sync_mismatch,
      message: "frontend state synchronization mismatch",
      details: %{
        screen: inspect(screen),
        field: field,
        expected: inspect(expected),
        actual: inspect(actual)
      }
    }
  end
end
