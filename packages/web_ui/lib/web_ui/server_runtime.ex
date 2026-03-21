defmodule WebUi.ServerRuntime do
  @moduledoc """
  Authoritative Phoenix-side runtime scaffold for `web_ui`.
  """

  alias UnifiedIUR.Element
  alias WebUi.ServerRuntime.{Error, EventRouter, State, SyncBoundary, ViewState}
  alias WebUi.Widget

  @spec modules() :: [module()]
  def modules do
    [__MODULE__, State, ViewState, EventRouter, SyncBoundary, Error]
  end

  @spec mount_native_screen(map(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def mount_native_screen(screen, opts \\ []) do
    with :ok <- validate_screen(screen) do
      {:ok, build_state(:native, screen, nil, opts)}
    end
  end

  @spec mount_iur_screen(Element.t(), keyword()) :: {:ok, State.t()} | {:error, Error.t()}
  def mount_iur_screen(%Element{} = element, opts \\ []) do
    screen = %{
      id: element.id || "canonical-screen",
      title: Keyword.get(opts, :title, "Canonical Screen"),
      root: WebUi.Renderer.render(element),
      metadata: %{source: :canonical, bridge: :phoenix_elm}
    }

    {:ok, build_state(:canonical, screen, element, opts)}
  end

  @spec frontend_payload(State.t()) :: map()
  def frontend_payload(%State{} = state) do
    ViewState.to_frontend_payload(state)
  end

  @spec frontend_envelope(State.t()) :: map()
  def frontend_envelope(%State{} = state) do
    SyncBoundary.hydration_envelope(state)
  end

  @spec receive_frontend_message(State.t(), map()) :: {:ok, map()} | {:error, Error.t()}
  def receive_frontend_message(%State{} = state, payload) do
    SyncBoundary.receive_frontend_message(state, payload)
  end

  @spec handle_event(State.t(), map()) :: {:ok, State.t()} | {:error, Error.t()}
  def handle_event(%State{} = state, translation) do
    with {:ok, route} <- EventRouter.route(state, translation) do
      apply_route(state, route)
    end
  end

  defp validate_screen(%{id: _id, title: _title, root: %Widget{}}), do: :ok

  defp validate_screen(_screen) do
    {:error,
     Error.new(
       :invalid_screen,
       "Expected a native screen with id, title, and WebUi.Widget root"
     )}
  end

  defp build_state(source_kind, screen, canonical_element, opts) do
    %State{
      runtime_id: Keyword.get(opts, :runtime_id, "web-ui-runtime"),
      source_kind: source_kind,
      title: screen.title,
      screen_id: screen.id,
      rendered_tree: screen.root,
      canonical_element: canonical_element,
      boundary_mode: if(source_kind == :canonical, do: :canonical_boundary, else: :native_local),
      diagnostics: [],
      event_log: [],
      metadata: Map.get(screen, :metadata, %{})
    }
  end

  defp apply_route(%State{} = state, %{route: :local_runtime, family: family}) do
    {:ok, State.record_event(state, %{mode: :local, family: family})}
  end

  defp apply_route(%State{} = state, %{
         route: :canonical_boundary,
         family: family,
         translation: translation
       }) do
    {:ok,
     state
     |> State.record_event(%{mode: :boundary, family: family})
     |> State.record_boundary_signal(translation.signal)}
  end
end
