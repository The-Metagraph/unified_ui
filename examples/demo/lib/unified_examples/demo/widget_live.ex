defmodule UnifiedExamples.Demo.WidgetLive do
  @moduledoc """
  LiveView for individual widget detail pages.
  """

  use Phoenix.LiveView

  alias UnifiedExamples.Demo.WidgetInfo
  alias UnifiedExamples.Shared.Catalog

  @impl true
  def mount(%{"widget_name" => widget_name}, _session, socket) do
    widget_name = String.to_existing_atom(widget_name)
    info = WidgetInfo.widget_info(widget_name)

    {:ok,
     socket
     |> assign(:widget_name, widget_name)
     |> assign(:info, info)
     |> assign(:page_title, String.capitalize(to_string(widget_name)))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="widget-page">
      <header class="widget-header">
        <.back_link />
        <h1><%= String.capitalize(to_string(@widget_name)) %></h1>
        <p class="widget-description"><%= @info.description %></p>
      </header>

      <section class="widget-preview">
        <h2>Preview</h2>
        <.render_widget widget={@widget_name} />
      </section>

      <section class="widget-events">
        <h2>Events</h2>
        <.events_table events={@info.events} />
      </section>

      <section class="widget-attributes">
        <h2>Attributes</h2>
        <.attributes_table attributes={@info.attributes} />
      </section>

      <section class="widget-links">
        <h2>Related Examples</h2>
        <.example_links widget={@widget_name} />
      </section>
    </div>

    <style>
      .widget-page {
        max-width: 1200px;
        margin: 0 auto;
        padding: 2rem;
      }

      .widget-header {
        margin-bottom: 2rem;
      }

      .widget-header h1 {
        font-size: 2rem;
        margin: 0 0 0.5rem 0;
      }

      .widget-description {
        color: var(--example-muted);
        font-size: 1.1rem;
      }

      .widget-preview {
        background: var(--example-elevated);
        border: 1px solid var(--example-border);
        border-radius: 12px;
        padding: 2rem;
        margin-bottom: 2rem;
      }

      .widget-preview h2 {
        font-size: 1.25rem;
        margin-top: 0;
      }

      .widget-events,
      .widget-attributes,
      .widget-links {
        background: var(--example-elevated);
        border: 1px solid var(--example-border);
        border-radius: 12px;
        padding: 1.5rem;
        margin-bottom: 2rem;
      }

      .widget-events h2,
      .widget-attributes h2,
      .widget-links h2 {
        font-size: 1.25rem;
        margin-top: 0;
        margin-bottom: 1rem;
      }

      table {
        width: 100%;
        border-collapse: collapse;
      }

      th, td {
        text-align: left;
        padding: 0.75rem;
        border-bottom: 1px solid var(--example-border);
      }

      th {
        font-weight: 600;
        color: var(--example-muted);
      }

      code {
        background: hsl(0 0% 15% / 0.5);
        padding: 0.2rem 0.4rem;
        border-radius: 4px;
        font-family: var(--example-font);
        font-size: 0.9em;
      }
    </style>
    """
  end

  defp render_widget(assigns) do
    ~H"""
    <div class="widget-preview-content">
      <%= if Map.has_key?(@info, :module) do %>
        <.render_widget_module widget={@widget_name} />
      <% else %>
        <div class="widget-not-implemented">
          <p>This widget is not yet implemented in LiveUI.</p>
        </div>
      <% end %>
    </div>
    """
  end

  defp render_widget_module(assigns) do
    ~H"""
    <div class="widget-preview-content">
      <%= case Catalog.entries() |> Enum.find(&(&1.widget == @widget)) do %>
        <% %{directory: directory} -> %>
          <div class="widget-preview-placeholder">
            <p>See <a href={"/examples/#{directory}"}><code><%= directory %></code></a> example for full preview.</p>
          </div>
        <% nil -> %>
          <div class="widget-preview-placeholder">
            <p>Preview coming soon.</p>
          </div>
      <% end %>
    </div>
    """
  end

  defp events_table(assigns) do
    ~H"""
    <table>
      <thead>
        <tr>
          <th>Event</th>
          <th>Description</th>
        </tr>
      </thead>
      <tbody>
        <%= for {event, description} <- assigns.events do %>
          <tr>
            <td><code><%= event %></code></td>
            <td><%= description %></td>
          </tr>
        <% end %>
        <%= if assigns.events == [] do %>
          <tr>
            <td colspan="2" class="empty">No documented events</td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  defp attributes_table(assigns) do
    ~H"""
    <table>
      <thead>
        <tr>
          <th>Attribute</th>
          <th>Type</th>
          <th>Required?</th>
        </tr>
      </thead>
      <tbody>
        <%= for {attr, info} <- assigns.attributes do %>
          <tr>
            <td><code><%= attr %></code></td>
            <td><%= info.type %></td>
            <td><%= if info.required?, do: "Yes", else: "No" %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  defp example_links(assigns) do
    ~H"""
    <div class="example-links">
      <%= case Catalog.entries() |> Enum.find(&(&1.widget == @widget)) do %>
        <% %{directory: directory} -> %>
          <a href={"/examples/#{directory}"} class="example-link">
            View full example →
          </a>
        <% nil -> %>
          <p class="empty">No example app available yet.</p>
      <% end %>
    </div>
    """
  end

  defp back_link(assigns) do
    ~H"""
    <a href="/" class="back-link">← All Widgets</a>
    """
  end
end
