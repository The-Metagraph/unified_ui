defmodule LiveUi.Components.DataViz do
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
      |> assign(:classes, Helpers.classes(descriptor, base_classes(kind)))
      |> assign(:style, Helpers.inline_style(descriptor))
      |> assign(:hook, Helpers.hook_name(descriptor))

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <%= case @kind do %>
        <% "gauge" -> %>
          <figure id={@id} class={@classes} style={@style}>
            <figcaption><%= value(@props, "label", "Gauge") %></figcaption>
            <progress value={value(@props, "value", 0)} max={value(@props, "max", 100)} min={value(@props, "min", 0)}></progress>
          </figure>
        <% "sparkline" -> %>
          <figure id={@id} class={@classes} style={@style}>
            <svg viewBox="0 0 100 20" role="img" aria-label="Sparkline">
              <polyline points={polyline_points(value(@props, "data", []))} fill="none" stroke="currentColor" />
            </svg>
          </figure>
        <% "bar_chart" -> %>
          <figure id={@id} class={@classes} style={@style}>
            <figcaption><%= value(@props, "title", "Bar Chart") %></figcaption>
            <ul class="live-ui-bar-chart">
              <%= for {label, amount} <- data_points(value(@props, "data", [])) do %>
                <li>
                  <span><%= label %></span>
                  <meter min="0" max={chart_max(value(@props, "data", []))} value={amount}></meter>
                </li>
              <% end %>
            </ul>
          </figure>
        <% "line_chart" -> %>
          <figure id={@id} class={@classes} style={@style}>
            <figcaption><%= value(@props, "title", "Line Chart") %></figcaption>
            <svg viewBox="0 0 100 20" role="img" aria-label={value(@props, "title", "Line Chart")}>
              <polyline points={polyline_points(value(@props, "data", []))} fill="none" stroke="currentColor" />
            </svg>
          </figure>
        <% "canvas" -> %>
          <figure id={@id} class={@classes} style={@style} data-live-ui-hook={@hook}>
            <figcaption><%= value(@props, "title", "Canvas") %></figcaption>
            <pre><%= inspect(value(@props, "draw", value(@props, "operations", [])), pretty: true) %></pre>
          </figure>
        <% _ -> %>
          <figure id={@id} class={@classes} style={@style}>
            <figcaption><%= value(@props, "title", "Chart") %></figcaption>
            <svg viewBox="0 0 100 20" role="img" aria-label={value(@props, "title", "Chart")}>
              <polyline points={polyline_points(value(@props, "series", []))} fill="none" stroke="currentColor" />
            </svg>
          </figure>
      <% end %>
    <% end %>
    """
  end

  def gauge(assigns), do: direct_leaf(assigns, "gauge", ["label", "max", "min", "value"])
  def sparkline(assigns), do: direct_leaf(assigns, "sparkline", ["data"])
  def bar_chart(assigns), do: direct_leaf(assigns, "bar_chart", ["data", "title"])
  def line_chart(assigns), do: direct_leaf(assigns, "line_chart", ["data", "title"])
  def chart(assigns), do: direct_leaf(assigns, "chart", ["series", "title"])
  def canvas(assigns), do: direct_leaf(assigns, "canvas", ["draw", "operations", "title"])

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

  defp data_points(data) when is_list(data) do
    Enum.map(data, fn
      {label, amount} ->
        {Helpers.scalar_string(label), normalize_number(amount)}

      %{"label" => label, "value" => amount} ->
        {Helpers.scalar_string(label), normalize_number(amount)}

      amount ->
        {"", normalize_number(amount)}
    end)
  end

  defp data_points(_data), do: []

  defp polyline_points(series) when is_list(series) do
    series
    |> Enum.map(fn
      {_label, value} -> value
      %{"value" => value} -> value
      value -> value
    end)
    |> Enum.with_index()
    |> Enum.map_join(" ", fn {value, index} -> "#{index * 20},#{20 - normalize_number(value)}" end)
  end

  defp polyline_points(_series), do: "0,20 100,20"

  defp chart_max(data) do
    data
    |> data_points()
    |> Enum.map(&elem(&1, 1))
    |> Enum.max(fn -> 100 end)
  end

  defp normalize_number(value) when is_integer(value), do: min(max(value, 0), 100)
  defp normalize_number(value) when is_float(value), do: value |> round() |> normalize_number()

  defp normalize_number(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> normalize_number(integer)
      _ -> 0
    end
  end

  defp normalize_number(_value), do: 0

  defp base_classes("canvas"),
    do: ["live-ui-canvas", "live-ui-dataviz", "live-ui-dataviz--canvas"]

  defp base_classes(kind) when kind in ["chart", "line_chart", "sparkline", "bar_chart"],
    do: ["live-ui-chart", "live-ui-dataviz", "live-ui-dataviz--#{kind}"]

  defp base_classes(kind), do: ["live-ui-dataviz", "live-ui-dataviz--#{kind}"]

  defp value(map, key, default) do
    atom_key = String.to_atom(key)
    Map.get(map, key, Map.get(map, atom_key, default))
  end
end
