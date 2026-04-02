defmodule LiveUi.Demo.Server.Live do
  @moduledoc false

  use Phoenix.LiveView

  alias LiveUi.Demo

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:runtime_state, nil)
     |> assign(:runtime_error, nil)
     |> assign(:page_title, "LiveUi Demo")}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    opts = route_opts(socket.assigns.live_action, params)

    case Demo.screen_assigns(opts) do
      {:ok, assigns} ->
        {:ok, runtime_state} = LiveUi.Runtime.mount(Demo.screen(), assigns: assigns)
        selected_example = LiveUi.Demo.Catalog.find_example(assigns.selected_example)

        {:noreply,
         socket
         |> assign(:runtime_state, runtime_state)
         |> assign(:runtime_error, nil)
         |> assign(:page_title, page_title(selected_example))}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:runtime_state, nil)
         |> assign(:runtime_error, reason)
         |> assign(:selected_example, nil)
         |> assign(:page_title, "LiveUi Demo")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main class="example-app-shell live-ui-demo-browser-app">
      <%= if @runtime_state do %>
        <.live_component
          module={LiveUi.Runtime.component()}
          id="live-ui-demo-runtime"
          runtime_state={@runtime_state}
          show_demo_panels={false}
        />
      <% else %>
        <pre data-live-ui-demo-error="true"><%= inspect(@runtime_error, pretty: true) %></pre>
      <% end %>
    </main>
    """
  end

  defp route_opts(:home, params) do
    [category: Map.get(params, "category")]
  end

  defp route_opts(:example, params) do
    [category: Map.get(params, "category"), example: Map.get(params, "example_id")]
  end

  defp page_title(nil), do: "LiveUi Demo"
  defp page_title(example), do: "#{example.title} | LiveUi Demo"
end
