defmodule LiveUi.Components.Layouts do
  @moduledoc false

  use Phoenix.Component

  alias LiveUi.Components.Helpers

  attr(:descriptor, :map, required: true)

  def render(assigns) do
    descriptor = assigns.descriptor
    props = Helpers.props(descriptor)
    children = Helpers.children(descriptor)
    kind = Helpers.kind(descriptor)

    assigns =
      assigns
      |> assign(:id, Helpers.id(descriptor))
      |> assign(:kind, kind)
      |> assign(:props, props)
      |> assign(:children, visible_children(children))
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-layout", "live-ui-layout--#{kind}"])
      )
      |> assign(:style, layout_style(kind, props, Helpers.inline_style(descriptor)))
      |> assign(:hook, Helpers.hook_name(descriptor))
      |> assign(:viewport_binding, Helpers.binding(descriptor, "on_scroll"))
      |> assign(:split_binding, Helpers.binding(descriptor, "on_resize_change"))

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <section
        id={@id}
        class={@classes}
        style={@style}
        data-live-ui-kind={@kind}
        data-live-ui-hook={@hook}
        data-live-ui-widget-id={@id}
      >
        <%= case @kind do %>
          <% "stack" -> %>
            <%= for {child, index} <- Enum.with_index(@children) do %>
              <div hidden={index != active_index(@props)} class="live-ui-stack__panel">
                <LiveUi.WidgetRegistry.render descriptor={child} />
              </div>
            <% end %>
          <% "zbox" -> %>
            <%= for {child, index} <- Enum.with_index(@children) do %>
              <div class="live-ui-zbox__layer" style={zbox_style(@props, child, index)}>
                <LiveUi.WidgetRegistry.render descriptor={child} />
              </div>
            <% end %>
          <% "viewport" -> %>
            <div
              class="live-ui-viewport__content"
              data-scroll-top={Map.get(@props, "scroll_top", 0)}
              data-scroll-left={Map.get(@props, "scroll_left", 0)}
              {Helpers.hook_event_attrs("scroll", @descriptor, @viewport_binding, %{
                "axis" => Map.get(@props, "axis", "both")
              })}
            >
              <%= for child <- @children do %>
                <LiveUi.WidgetRegistry.render descriptor={child} />
              <% end %>
            </div>
          <% "split_pane" -> %>
            <%= for {child, index} <- Enum.with_index(@children) do %>
              <div
                class="live-ui-split-pane__pane"
                data-pane-index={index}
                style={split_pane_style(@props, @children, index)}
              >
                <LiveUi.WidgetRegistry.render descriptor={child} />
              </div>
              <button
                :if={index < length(@children) - 1}
                type="button"
                class="live-ui-split-pane__handle"
                aria-label="Resize pane"
                data-pane-index={index}
                {Helpers.hook_event_attrs("resize", @descriptor, @split_binding, %{
                  "orientation" => split_orientation(@props),
                  "pane_index" => index,
                  "sizes" => split_sizes(@props, @children)
                })}
              >
                <span aria-hidden="true">|</span>
              </button>
            <% end %>
          <% _ -> %>
            <%= for child <- @children do %>
              <LiveUi.WidgetRegistry.render descriptor={child} />
            <% end %>
        <% end %>
      </section>
    <% end %>
    """
  end

  def vbox(assigns), do: direct_layout(assigns, "vbox")
  def hbox(assigns), do: direct_layout(assigns, "hbox")
  def grid(assigns), do: direct_layout(assigns, "grid")
  def stack(assigns), do: direct_layout(assigns, "stack")
  def zbox(assigns), do: direct_layout(assigns, "zbox")
  def viewport(assigns), do: direct_layout(assigns, "viewport")
  def split_pane(assigns), do: direct_layout(assigns, "split_pane")

  defp visible_children(children) do
    Enum.filter(children, &Helpers.visible?/1)
  end

  defp direct_children(assigns, "split_pane"), do: Map.get(assigns, :pane, [])
  defp direct_children(assigns, "stack"), do: Map.get(assigns, :panel, [])
  defp direct_children(assigns, "zbox"), do: Map.get(assigns, :layer, [])
  defp direct_children(assigns, _kind), do: Map.get(assigns, :inner_block, [])

  defp direct_layout(assigns, kind) do
    descriptor = %{
      id: Map.get(assigns, :id, Map.get(assigns, "id")),
      kind: kind,
      props: direct_layout_props(assigns),
      signal_bindings: Map.get(assigns, :signal_bindings, Map.get(assigns, "signal_bindings", []))
    }

    props = Helpers.props(descriptor)

    assigns =
      assigns
      |> assign(:descriptor, descriptor)
      |> assign(:id, Helpers.id(descriptor))
      |> assign(:kind, kind)
      |> assign(:props, props)
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-layout", "live-ui-layout--#{kind}"])
      )
      |> assign(:style, layout_style(kind, props, Helpers.inline_style(descriptor)))
      |> assign(:hook, Helpers.hook_name(descriptor))
      |> assign(:viewport_binding, Helpers.binding(descriptor, "on_scroll"))
      |> assign(:split_binding, Helpers.binding(descriptor, "on_resize_change"))
      |> assign_new(:inner_block, fn -> [] end)
      |> assign(:direct_children, direct_children(assigns, kind))

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <section
        id={@id}
        class={@classes}
        style={@style}
        data-live-ui-kind={@kind}
        data-live-ui-hook={@hook}
        data-live-ui-widget-id={@id}
      >
        <%= case @kind do %>
          <% "stack" -> %>
            <%= for {slot, index} <- Enum.with_index(@direct_children) do %>
              <div hidden={index != active_index(@props)} class="live-ui-stack__panel">
                <%= render_slot(slot) %>
              </div>
            <% end %>
          <% "zbox" -> %>
            <%= for {slot, index} <- Enum.with_index(@direct_children) do %>
              <div class="live-ui-zbox__layer" style={zbox_slot_style(@props, index)}>
                <%= render_slot(slot) %>
              </div>
            <% end %>
          <% "viewport" -> %>
            <div
              class="live-ui-viewport__content"
              data-scroll-top={Map.get(@props, "scroll_top", 0)}
              data-scroll-left={Map.get(@props, "scroll_left", 0)}
              {Helpers.hook_event_attrs("scroll", @descriptor, @viewport_binding, %{
                "axis" => Map.get(@props, "axis", "both")
              })}
            >
              <%= render_slot(@inner_block) %>
            </div>
          <% "split_pane" -> %>
            <%= for {slot, index} <- Enum.with_index(@direct_children) do %>
              <div
                class="live-ui-split-pane__pane"
                data-pane-index={index}
                style={split_pane_style_for_count(@props, length(@direct_children), index)}
              >
                <%= render_slot(slot) %>
              </div>
              <button
                :if={index < length(@direct_children) - 1}
                type="button"
                class="live-ui-split-pane__handle"
                aria-label="Resize pane"
                data-pane-index={index}
                {Helpers.hook_event_attrs("resize", @descriptor, @split_binding, %{
                  "orientation" => split_orientation(@props),
                  "pane_index" => index,
                  "sizes" => split_sizes_for_count(@props, length(@direct_children))
                })}
              >
                <span aria-hidden="true">|</span>
              </button>
            <% end %>
          <% _ -> %>
            <%= render_slot(@inner_block) %>
        <% end %>
      </section>
    <% end %>
    """
  end

  defp direct_layout_props(assigns) do
    Helpers.direct_props(assigns, %{
      "active_index" => Map.get(assigns, :active_index, Map.get(assigns, "active_index")),
      "align_items" => Map.get(assigns, :align_items, Map.get(assigns, "align_items")),
      "axis" => Map.get(assigns, :axis, Map.get(assigns, "axis")),
      "columns" => Map.get(assigns, :columns, Map.get(assigns, "columns")),
      "gap" => Map.get(assigns, :gap, Map.get(assigns, "gap")),
      "initial_split" => Map.get(assigns, :initial_split, Map.get(assigns, "initial_split")),
      "justify_content" =>
        Map.get(assigns, :justify_content, Map.get(assigns, "justify_content")),
      "orientation" => Map.get(assigns, :orientation, Map.get(assigns, "orientation")),
      "padding" => Map.get(assigns, :padding, Map.get(assigns, "padding")),
      "positions" => Map.get(assigns, :positions, Map.get(assigns, "positions")),
      "rows" => Map.get(assigns, :rows, Map.get(assigns, "rows")),
      "scroll_left" => Map.get(assigns, :scroll_left, Map.get(assigns, "scroll_left")),
      "scroll_top" => Map.get(assigns, :scroll_top, Map.get(assigns, "scroll_top")),
      "sizes" => Map.get(assigns, :sizes, Map.get(assigns, "sizes")),
      "spacing" => Map.get(assigns, :spacing, Map.get(assigns, "spacing"))
    })
  end

  defp layout_style(kind, props, base_style) do
    css =
      []
      |> add_css("display", display_for(kind))
      |> add_css("flex-direction", direction_for(kind))
      |> add_css("gap", px(Map.get(props, "spacing", Map.get(props, "gap"))))
      |> add_css("padding", px(Map.get(props, "padding")))
      |> add_css("align-items", css_value(Map.get(props, "align_items")))
      |> add_css("justify-content", css_value(Map.get(props, "justify_content")))
      |> add_css("grid-template-columns", track_list(Map.get(props, "columns")))
      |> add_css("grid-template-rows", track_list(Map.get(props, "rows")))
      |> add_css("overflow", if(kind == "viewport", do: "auto", else: nil))
      |> add_css("position", if(kind == "zbox", do: "relative", else: nil))
      |> add_css("--live-ui-split", split_value(props))
      |> Enum.reverse()
      |> Enum.join("; ")

    join_css(base_style, css)
  end

  defp display_for(kind) when kind in ["vbox", "hbox", "split_pane"], do: "flex"
  defp display_for("grid"), do: "grid"
  defp display_for(_kind), do: "block"

  defp direction_for("vbox"), do: "column"
  defp direction_for("hbox"), do: "row"
  defp direction_for("split_pane"), do: nil
  defp direction_for(_kind), do: nil

  defp split_value(props) do
    case split_sizes(props, []) do
      [first | _rest] -> "#{first}%"
      _other -> nil
    end
  end

  defp active_index(props) do
    case Map.get(props, "active_index", 0) do
      value when is_integer(value) and value >= 0 ->
        value

      value when is_binary(value) ->
        case Integer.parse(value) do
          {index, ""} -> index
          _ -> 0
        end

      _ ->
        0
    end
  end

  defp zbox_style(props, child, index) do
    positions = Map.get(props, "positions", %{})
    id = Helpers.id(child)
    child_position = Map.get(positions, id, Map.get(positions, Integer.to_string(index), %{}))

    []
    |> add_css("position", "absolute")
    |> add_css("left", px(Map.get(child_position, "x")))
    |> add_css("top", px(Map.get(child_position, "y")))
    |> add_css("width", px(Map.get(child_position, "width")))
    |> add_css("height", px(Map.get(child_position, "height")))
    |> add_css(
      "z-index",
      css_value(Map.get(child_position, "z", Map.get(child_position, "z_index")))
    )
    |> Enum.reverse()
    |> Enum.join("; ")
  end

  defp track_list(list) when is_list(list), do: Enum.map_join(list, " ", &css_value/1)
  defp track_list(_list), do: nil

  defp px(value) when is_integer(value), do: "#{value}px"
  defp px(value) when is_binary(value), do: value
  defp px(_value), do: nil

  defp split_pane_style(props, children, index) do
    case Enum.at(split_sizes(props, children), index) do
      nil -> nil
      size -> "flex: 0 0 #{size}%"
    end
  end

  defp split_pane_style_for_count(props, count, index) do
    case Enum.at(split_sizes_for_count(props, count), index) do
      nil -> nil
      size -> "flex: 0 0 #{size}%"
    end
  end

  defp split_sizes(props, children) do
    case normalize_sizes(Map.get(props, "sizes")) do
      sizes when length(sizes) == length(children) and sizes != [] ->
        sizes

      _other ->
        fallback_split_sizes(props, children)
    end
  end

  defp split_sizes_for_count(props, count) do
    phantom_children = List.duplicate(:pane, count)
    split_sizes(props, phantom_children)
  end

  defp fallback_split_sizes(props, children) do
    case {length(children), normalize_size(Map.get(props, "initial_split"))} do
      {2, split} when is_integer(split) and split > 0 and split < 100 ->
        [split, 100 - split]

      {count, _split} when count > 0 ->
        base = div(100, count)
        remainder = rem(100, count)

        Enum.map(0..(count - 1), fn index ->
          if index < remainder, do: base + 1, else: base
        end)

      _other ->
        []
    end
  end

  defp normalize_sizes(sizes) when is_list(sizes) do
    sizes
    |> Enum.map(&normalize_size/1)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_sizes(_sizes), do: []

  defp normalize_size(value) when is_integer(value), do: value

  defp normalize_size(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> integer
      _other -> nil
    end
  end

  defp normalize_size(_value), do: nil

  defp zbox_slot_style(props, index) do
    positions = Map.get(props, "positions", %{})
    child_position = Map.get(positions, Integer.to_string(index), %{})

    []
    |> add_css("position", "absolute")
    |> add_css("left", px(Map.get(child_position, "x")))
    |> add_css("top", px(Map.get(child_position, "y")))
    |> add_css("width", px(Map.get(child_position, "width")))
    |> add_css("height", px(Map.get(child_position, "height")))
    |> add_css(
      "z-index",
      css_value(Map.get(child_position, "z", Map.get(child_position, "z_index")))
    )
    |> Enum.reverse()
    |> Enum.join("; ")
  end

  defp split_orientation(props) do
    case Map.get(props, "orientation", "horizontal") do
      value when value in ["horizontal", "vertical"] -> value
      value when value in [:horizontal, :vertical] -> Atom.to_string(value)
      _other -> "horizontal"
    end
  end

  defp css_value(nil), do: nil
  defp css_value(value) when is_boolean(value), do: if(value, do: "true", else: "false")
  defp css_value(value) when is_atom(value), do: Atom.to_string(value)
  defp css_value(value) when is_binary(value), do: value
  defp css_value(value) when is_integer(value), do: Integer.to_string(value)
  defp css_value(_value), do: nil

  defp add_css(acc, _property, nil), do: acc
  defp add_css(acc, property, value), do: ["#{property}: #{value}" | acc]

  defp join_css(nil, css), do: blank_to_nil(css)
  defp join_css(base, ""), do: blank_to_nil(base)
  defp join_css(base, css), do: Enum.join(Enum.reject([base, css], &(&1 in [nil, ""])), "; ")

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value
end
