defmodule LiveUi.Components.Extensions do
  @moduledoc false

  use Phoenix.Component

  alias LiveUi.Components.Helpers

  attr(:descriptor, :map, required: true)

  def render(assigns) do
    descriptor = assigns.descriptor
    props = Helpers.props(descriptor)
    kind = Helpers.kind(descriptor)

    assigns =
      assigns
      |> assign(:id, Helpers.id(descriptor))
      |> assign(:kind, kind)
      |> assign(:props, props)
      |> assign(
        :classes,
        Helpers.classes(descriptor, [
          "live-ui-extension",
          "live-ui-extension--#{kind}"
        ])
      )
      |> assign(:style, Helpers.inline_style(descriptor))
      |> assign(:hook, Helpers.hook_name(descriptor))
      |> assign(
        :filter_attrs,
        Helpers.event_attrs("change", descriptor, Helpers.binding(descriptor, "on_change"))
      )
      |> assign(
        :refresh_attrs,
        Helpers.event_attrs(
          "click",
          descriptor,
          Helpers.binding(descriptor, ["action", "on_select"])
        )
      )
      |> assign(:process_binding, Helpers.binding(descriptor, "on_process_select"))

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <%= case @kind do %>
        <% "log_viewer" -> %>
          <section id={@id} class={@classes} style={@style} data-live-ui-hook={@hook}>
            <header class="live-ui-extension__header">
              <h3>Log Viewer</h3>
              <button :if={@refresh_attrs != []} type="button" {@refresh_attrs}>Refresh</button>
            </header>
            <input
              :if={Map.has_key?(@props, "filter") or @filter_attrs != []}
              type="search"
              name="filter"
              value={Map.get(@props, "filter", "")}
              placeholder="Filter logs"
              {@filter_attrs}
            />
            <ol data-live-ui-source={Map.get(@props, "source")}>
              <%= for line <- Map.get(@props, "lines", []) do %>
                <li><%= Helpers.scalar_string(line) %></li>
              <% end %>
            </ol>
          </section>
        <% "stream_widget" -> %>
          <section id={@id} class={@classes} style={@style} data-live-ui-hook={@hook}>
            <header class="live-ui-extension__header">
              <h3><%= Map.get(@props, "title", "Stream") %></h3>
              <button :if={@refresh_attrs != []} type="button" {@refresh_attrs}>Refresh</button>
            </header>
            <ul data-live-ui-buffer-size={Map.get(@props, "buffer_size")}>
              <%= for item <- Map.get(@props, "items", Map.get(@props, "lines", [])) do %>
                <li><%= Helpers.scalar_string(item) %></li>
              <% end %>
            </ul>
          </section>
        <% "process_monitor" -> %>
          <section id={@id} class={@classes} style={@style} data-live-ui-hook={@hook}>
            <header class="live-ui-extension__header">
              <h3>Process Monitor</h3>
              <span :if={Map.get(@props, "node")} data-live-ui-node={Map.get(@props, "node")}>
                <%= Map.get(@props, "node") %>
              </span>
            </header>
            <ul>
              <%= for process <- Map.get(@props, "processes", []) do %>
                <% pid = process_value(process, "pid") %>
                <% process_attrs =
                  Helpers.event_attrs(
                    "click",
                    nil,
                    @descriptor,
                    @process_binding,
                    %{
                      "name" => process_value(process, "name"),
                      "pid" => pid
                    }
                  ) %>
                <li>
                  <button
                    :if={@process_binding}
                    type="button"
                    class={["live-ui-process-monitor__process", if(process_selected?(@props, pid), do: "is-selected")]}
                    {process_attrs}
                  >
                    <%= process_label(process) %>
                  </button>
                  <span :if={is_nil(@process_binding)}>
                    <%= process_label(process) %>
                  </span>
                </li>
              <% end %>
            </ul>
          </section>
        <% _ -> %>
          <section id={@id} class={@classes} style={@style} data-live-ui-hook={@hook}>
            <header><%= @kind |> to_string() |> String.replace("_", " ") %></header>
            <div data-live-ui-state={inspect(Map.take(@props, ["auto_refresh", "buffer_size", "filter", "lines", "node", "refresh_interval", "source"]))}>
              <%= inspect(@props, pretty: true) %>
            </div>
          </section>
      <% end %>
    <% end %>
    """
  end

  def log_viewer(assigns), do: direct_leaf(assigns, "log_viewer", ["filter", "lines", "source"])

  def stream_widget(assigns) do
    direct_leaf(assigns, "stream_widget", ["buffer_size", "items", "lines", "title"])
  end

  def process_monitor(assigns) do
    direct_leaf(assigns, "process_monitor", ["node", "processes", "selected_pid"])
  end

  defp direct_leaf(assigns, kind, prop_keys) do
    extra_props =
      prop_keys
      |> Enum.map(fn key ->
        {key, Map.get(assigns, String.to_atom(key), Map.get(assigns, key))}
      end)
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> Map.new()

    descriptor = Helpers.direct_descriptor(assigns, kind, extra_props)
    assigns = assign(assigns, :descriptor, descriptor)

    ~H"""
    <.render descriptor={@descriptor} />
    """
  end

  defp process_label(%{} = process) do
    [process_value(process, "name"), process_value(process, "pid")]
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.join(" ")
  end

  defp process_label(process), do: Helpers.scalar_string(process)

  defp process_value(%{} = process, key) do
    Map.get(process, key, Map.get(process, String.to_atom(key)))
  rescue
    ArgumentError -> nil
  end

  defp process_value(_process, _key), do: nil

  defp process_selected?(props, pid) do
    Helpers.scalar_string(Map.get(props, "selected_pid")) == Helpers.scalar_string(pid)
  end
end
