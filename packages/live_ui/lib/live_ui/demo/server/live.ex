defmodule LiveUi.Demo.Server.Live do
  @moduledoc false

  use Phoenix.LiveView

  alias LiveUi.Demo

  @impl true
  def mount(_params, _session, socket) do
    catalog = Demo.catalog()

    {:ok,
     socket
     |> assign(:categories, catalog.categories)
     |> assign(:path_counts, catalog.path_counts)
     |> assign(:total_examples, catalog.total_examples)
     |> assign(:runtime_state, nil)
     |> assign(:runtime_error, nil)
     |> assign(:selected_category, nil)
     |> assign(:selected_example, nil)
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
         |> assign(:selected_category, assigns.selected_category)
         |> assign(:selected_example, selected_example)
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
      <header class="example-app-header">
        <div class="example-app-header-top">
          <p class="example-app-kicker">live_ui package demo</p>
          <span class="example-app-widget">browser host</span>
        </div>

        <h1 class="example-app-title">Live UI Workbench</h1>
        <p class="example-app-summary">
          Browse the package-local demo through a real Phoenix LiveView host, using the same
          `LiveUi.Runtime` component the package exposes everywhere else.
        </p>
        <p class="example-app-notes">
          Native screen events now stay inside the shared server-authoritative runtime, so the
          lane picker and example navigation are clickable in the browser instead of being static
          HTML output.
        </p>
        <p class="example-app-notes live-ui-demo-status">
          <%= current_status(@selected_category, @selected_example) %>
        </p>

        <nav class="live-ui-demo-launches" aria-label="Featured demo routes">
          <.link patch={Demo.path()} class="live-ui-demo-link">
            Overview
          </.link>

          <%= for category <- @categories do %>
            <.link
              patch={Demo.path(example: category.featured_example.id, category: category.id)}
              class="live-ui-demo-link"
            >
              <span><%= category.title %></span>
              <small><%= category.featured_example.title %></small>
            </.link>
          <% end %>
        </nav>

        <div class="live-ui-demo-metrics">
          <span>Examples: <%= @total_examples %></span>
          <span>Native: <%= Map.get(@path_counts, :native, 0) %></span>
          <span>Canonical: <%= Map.get(@path_counts, :canonical, 0) %></span>
          <span>Mixed: <%= Map.get(@path_counts, :mixed, 0) %></span>
        </div>
      </header>

      <section class="example-app-runtime">
        <%= if @runtime_state do %>
          <.live_component
            module={LiveUi.Runtime.component()}
            id="live-ui-demo-runtime"
            runtime_state={@runtime_state}
          />
        <% else %>
          <pre data-live-ui-demo-error="true"><%= inspect(@runtime_error, pretty: true) %></pre>
        <% end %>
      </section>
    </main>
    """
  end

  defp route_opts(:home, params) do
    [category: Map.get(params, "category")]
  end

  defp route_opts(:example, params) do
    [category: Map.get(params, "category"), example: Map.get(params, "example_id")]
  end

  defp current_status(category, nil) do
    category_label =
      category
      |> LiveUi.Demo.Catalog.normalize_category()
      |> case do
        nil -> "native"
        value -> Atom.to_string(value)
      end

    "Current lane: #{category_label}. Pick a featured route above or use the in-runtime sidebar to drill down."
  end

  defp current_status(category, example) do
    category_label =
      category
      |> LiveUi.Demo.Catalog.normalize_category()
      |> case do
        nil -> "native"
        value -> Atom.to_string(value)
      end

    "Current lane: #{category_label}. Focused example: #{example.title}."
  end

  defp page_title(nil), do: "LiveUi Demo"
  defp page_title(example), do: "#{example.title} | LiveUi Demo"
end
