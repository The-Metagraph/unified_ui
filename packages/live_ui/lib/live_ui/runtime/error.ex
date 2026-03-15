defmodule LiveUi.Runtime.Error do
  @moduledoc """
  Deterministic runtime error contract for `live_ui`.
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
      message: "screen module does not satisfy the LiveUi.Screen contract",
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
end
