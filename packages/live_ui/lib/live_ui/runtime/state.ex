defmodule LiveUi.Runtime.State do
  @moduledoc """
  Server-authoritative runtime state for mounted `live_ui` screens.
  """

  alias LiveUi.Runtime.{BrowserBridge, Error}

  @enforce_keys [:screen, :assigns, :mode, :event_routes, :bridge_hooks]
  defstruct [:screen, :assigns, :mode, :event_routes, :bridge_hooks]

  @type mode :: :native | :canonical

  @type t :: %__MODULE__{
          screen: module(),
          assigns: map(),
          mode: mode(),
          event_routes: %{optional(String.t()) => atom()},
          bridge_hooks: [atom()]
        }

  @spec mount(module(), keyword()) :: {:ok, t()} | {:error, Error.t()}
  def mount(screen, opts \\ []) do
    with :ok <- validate_screen(screen),
         {:ok, defaults} <- normalize_defaults(screen, screen.mount_defaults()) do
      initial_assigns = Keyword.get(opts, :assigns, %{})

      {:ok,
       %__MODULE__{
         screen: screen,
         assigns: Map.merge(defaults, initial_assigns),
         mode: Keyword.get(opts, :mode, :native),
         event_routes: screen.event_routes(),
         bridge_hooks: BrowserBridge.normalize_hooks(screen.bridge_hooks())
       }}
    end
  end

  @spec handle_event(t(), String.t(), map()) :: {:ok, t()} | {:error, Error.t()}
  def handle_event(%__MODULE__{} = state, event, payload)
      when is_binary(event) and is_map(payload) do
    case Map.fetch(state.event_routes, event) do
      {:ok, route} ->
        apply_event(state, route, payload)

      :error ->
        {:error, Error.invalid_event_route(state.screen, event)}
    end
  end

  defp apply_event(%__MODULE__{} = state, route, payload) do
    case state.screen.handle_event(route, payload, state.assigns) do
      {:ok, updated_assigns} when is_map(updated_assigns) ->
        {:ok, %{state | assigns: updated_assigns}}

      {:error, reason} ->
        {:error, Error.invalid_event_result(state.screen, route, {:error, reason})}

      other ->
        {:error, Error.invalid_event_result(state.screen, route, other)}
    end
  end

  defp validate_screen(screen) when is_atom(screen) do
    if Code.ensure_loaded?(screen) and function_exported?(screen, :id, 0) and
         function_exported?(screen, :mount_defaults, 0) and function_exported?(screen, :render, 1) and
         function_exported?(screen, :event_routes, 0) and
         function_exported?(screen, :bridge_hooks, 0) and
         function_exported?(screen, :handle_event, 3) do
      :ok
    else
      {:error, Error.invalid_screen_module(screen)}
    end
  end

  defp normalize_defaults(_screen, defaults) when is_map(defaults), do: {:ok, defaults}
  defp normalize_defaults(screen, _other), do: {:error, Error.invalid_mount_defaults(screen)}
end
