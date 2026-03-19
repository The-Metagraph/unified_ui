defmodule WebUi.ServerRuntime.State do
  @moduledoc """
  Server-authoritative runtime state for mounted `web_ui` screens.

  This module manages the server-side state that drives both Phoenix
  rendering and Elm frontend hydration. The state is always maintained
  authoritatively on the server, with the Elm frontend acting as a
  projection.
  """

  alias WebUi.ServerRuntime.{Error, FrontendSync}

  @enforce_keys [:screen, :assigns, :mode, :event_routes, :frontend_sync, :mounted_at]
  defstruct [:screen, :assigns, :mode, :event_routes, :frontend_sync, :mounted_at]

  @type mode :: :native | :canonical

  @type t :: %__MODULE__{
          screen: module(),
          assigns: map(),
          mode: mode(),
          event_routes: %{optional(String.t()) => atom()},
          frontend_sync: FrontendSync.t(),
          mounted_at: DateTime.t()
        }

  @doc """
  Mounts a screen module with the given options.
  """
  @spec mount(module(), keyword()) :: {:ok, t()} | {:error, Error.t()}
  def mount(screen, opts \\ []) do
    with :ok <- validate_screen(screen),
         {:ok, defaults} <- normalize_defaults(screen, screen.mount_defaults()),
         {:ok, frontend_sync} <- FrontendSync.build(screen, defaults) do
      initial_assigns = Keyword.get(opts, :assigns, %{})

      {:ok,
       %__MODULE__{
         screen: screen,
         assigns: Map.merge(defaults, initial_assigns),
         mode: Keyword.get(opts, :mode, :native),
         event_routes: screen.event_routes(),
         frontend_sync: frontend_sync,
         mounted_at: DateTime.utc_now()
       }}
    end
  end

  @doc """
  Handles an incoming event from either the Phoenix LiveView or Elm frontend.
  """
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

  @doc """
  Returns the current frontend sync state for hydration.
  """
  @spec frontend_state(t()) :: map()
  def frontend_state(%__MODULE__{} = state) do
    FrontendSync.to_map(state.frontend_sync, state.assigns)
  end

  @doc """
  Updates the frontend sync after state changes.
  """
  @spec update_sync(t(), map()) :: t()
  def update_sync(%__MODULE__{} = state, new_assigns) do
    %{state | assigns: new_assigns, frontend_sync: FrontendSync.update(state.frontend_sync, new_assigns)}
  end

  # Private functions

  defp apply_event(%__MODULE__{} = state, route, payload) do
    case state.screen.handle_event(route, payload, state.assigns) do
      {:ok, updated_assigns} when is_map(updated_assigns) ->
        {:ok, update_sync(state, updated_assigns)}

      {:error, reason} ->
        {:error, Error.invalid_event_result(state.screen, route, {:error, reason})}

      other ->
        {:error, Error.invalid_event_result(state.screen, route, other)}
    end
  end

  defp validate_screen(screen) when is_atom(screen) do
    required_functions = [
      {:id, 0},
      {:mount_defaults, 0},
      {:render, 1},
      {:event_routes, 0},
      {:handle_event, 3},
      {:frontend_schema, 0}
    ]

    has_all_required? =
      Enum.all?(required_functions, fn {func, arity} ->
        function_exported?(screen, func, arity)
      end)

    if Code.ensure_loaded?(screen) and has_all_required? do
      :ok
    else
      {:error, Error.invalid_screen_module(screen)}
    end
  end

  defp normalize_defaults(_screen, defaults) when is_map(defaults), do: {:ok, defaults}
  defp normalize_defaults(screen, _other), do: {:error, Error.invalid_mount_defaults(screen)}
end
