defmodule WebUi.Server.State do
  @moduledoc """
  Authoritative Phoenix-side runtime state for mounted `web_ui` screens.
  """

  alias WebUi.Server.{Error, Sync, ViewState}

  @enforce_keys [:screen, :assigns, :mode, :event_routes, :view_state, :revision]
  defstruct [:screen, :assigns, :mode, :event_routes, :view_state, :revision]

  @type mode :: :native | :canonical

  @type t :: %__MODULE__{
          screen: module(),
          assigns: map(),
          mode: mode(),
          event_routes: %{optional(String.t()) => atom()},
          view_state: ViewState.t(),
          revision: non_neg_integer()
        }

  @spec mount(module(), keyword()) :: {:ok, t()} | {:error, Error.t()}
  def mount(screen, opts \\ []) do
    with :ok <- validate_screen(screen),
         {:ok, defaults} <- normalize_defaults(screen, screen.mount_defaults()),
         assigns <- Map.merge(defaults, Keyword.get(opts, :assigns, %{})),
         revision <- Keyword.get(opts, :revision, 0),
         mode <- Keyword.get(opts, :mode, :native),
         {:ok, view_state} <- ViewState.build(screen, assigns, revision: revision, mode: mode) do
      {:ok,
       %__MODULE__{
         screen: screen,
         assigns: assigns,
         mode: mode,
         event_routes: screen.event_routes(),
         view_state: view_state,
         revision: revision
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

  @spec sync_envelope(t(), keyword()) :: {:ok, map()}
  def sync_envelope(%__MODULE__{view_state: view_state}, opts \\ []) do
    Sync.outbound(view_state, opts)
  end

  defp apply_event(%__MODULE__{} = state, route, payload) do
    case state.screen.handle_event(route, payload, state.assigns) do
      {:ok, updated_assigns} when is_map(updated_assigns) ->
        revision = state.revision + 1

        with {:ok, view_state} <-
               ViewState.build(state.screen, updated_assigns,
                 revision: revision,
                 mode: state.mode
               ) do
          {:ok, %{state | assigns: updated_assigns, revision: revision, view_state: view_state}}
        end

      {:error, reason} ->
        {:error, Error.invalid_event_result(state.screen, route, {:error, reason})}

      other ->
        {:error, Error.invalid_event_result(state.screen, route, other)}
    end
  end

  defp validate_screen(screen) when is_atom(screen) do
    if Code.ensure_loaded?(screen) and function_exported?(screen, :id, 0) and
         function_exported?(screen, :title, 0) and
         function_exported?(screen, :mount_defaults, 0) and
         function_exported?(screen, :event_routes, 0) and
         function_exported?(screen, :view, 1) and
         function_exported?(screen, :handle_event, 3) and
         function_exported?(screen, :frontend_boot, 0) do
      :ok
    else
      {:error, Error.invalid_screen_module(screen)}
    end
  end

  defp normalize_defaults(_screen, defaults) when is_map(defaults), do: {:ok, defaults}
  defp normalize_defaults(screen, _other), do: {:error, Error.invalid_mount_defaults(screen)}
end
