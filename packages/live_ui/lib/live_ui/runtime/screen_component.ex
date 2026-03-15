defmodule LiveUi.Runtime.ScreenComponent do
  @moduledoc """
  Shared LiveComponent host for mounted native and renderer-driven screens.
  """

  use Phoenix.LiveComponent

  alias LiveUi.Runtime.State

  @impl true
  def update(%{runtime_state: %State{} = runtime_state} = assigns, socket) do
    {:ok, assign(socket, Map.put(assigns, :runtime_state, runtime_state))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section id={@id} data-live-ui-runtime="screen">
      <%= render_screen(@runtime_state) %>
    </section>
    """
  end

  defp render_screen(runtime_state) do
    rendered_assigns =
      runtime_state.assigns
      |> Map.put(:runtime_state, runtime_state)
      |> Map.put_new(:id, to_string(runtime_state.screen.id()))

    runtime_state.screen.render(rendered_assigns)
  end
end
