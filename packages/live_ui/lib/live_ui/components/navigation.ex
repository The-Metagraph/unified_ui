defmodule LiveUi.Components.Navigation do
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
      |> assign(:children, children)
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-navigation", "live-ui-navigation--#{kind}"])
      )
      |> assign(:style, Helpers.inline_style(descriptor))
      |> assign(:hook, Helpers.hook_name(descriptor))
      |> assign(
        :menu_item_attrs,
        Helpers.event_attrs("click", descriptor, action_binding(descriptor))
      )
      |> assign(
        :command_attrs,
        Helpers.event_attrs("click", descriptor, action_binding(descriptor))
      )
      |> assign(:tree_binding, Helpers.binding(descriptor, ["on_select", "on_toggle"]))
      |> assign(
        :palette_form_attrs,
        Helpers.merge_attrs([
          Helpers.event_attrs("change", descriptor, Helpers.binding(descriptor, "on_change")),
          Helpers.event_attrs(
            "submit",
            descriptor,
            Helpers.binding(descriptor, ["on_submit", "action"])
          )
        ])
      )
      |> assign(
        :palette_hook_attrs,
        Helpers.hook_event_attrs(
          "change",
          descriptor,
          Helpers.binding(descriptor, "on_change"),
          %{
            "active_command_id" => Map.get(props, "active_command_id"),
            "open" => Map.get(props, "open", true)
          }
        )
      )

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <%= case @kind do %>
        <% "menu_item" -> %>
          <li id={@id} class={@classes}>
            <button type="button" disabled={Helpers.truthy?(Map.get(@props, "disabled", false))} {@menu_item_attrs}>
              <%= Map.get(@props, "label", "Item") %>
            </button>
            <%= if @children != [] do %>
              <ul><%= for child <- @children do %><LiveUi.WidgetRegistry.render descriptor={child} /><% end %></ul>
            <% end %>
          </li>
        <% "menu" -> %>
          <nav id={@id} class={@classes} style={@style}><ul><%= for child <- @children do %><LiveUi.WidgetRegistry.render descriptor={child} /><% end %></ul></nav>
        <% "context_menu" -> %>
          <div id={@id} class={@classes} style={@style}><ul><%= for child <- @children do %><LiveUi.WidgetRegistry.render descriptor={child} /><% end %></ul></div>
        <% "tab" -> %>
          <button id={@id} type="button" class={@classes} disabled={Helpers.truthy?(Map.get(@props, "disabled", false))}><%= Map.get(@props, "label", "Tab") %></button>
        <% "tabs" -> %>
          <section id={@id} class={@classes} style={@style}>
            <div class="live-ui-tabs__bar">
              <%= for tab <- @children do %>
                <% tab_attrs =
                  Helpers.event_attrs(
                    "click",
                    nil,
                    @descriptor,
                    Helpers.binding(@descriptor, "on_change"),
                    %{"tab_id" => Helpers.id(tab)}
                  ) %>
                <button
                  type="button"
                  class={["live-ui-tabs__tab", if(Helpers.id(tab) == active_tab(@props, @children), do: "is-active")]}
                  disabled={Helpers.truthy?(Map.get(Helpers.props(tab), "disabled", false))}
                  {tab_attrs ++ [{"phx-value-event_click_tab_index", to_string(tab_index(tab, @children))}]}
                >
                  <%= Map.get(Helpers.props(tab), "label", Helpers.id(tab)) %>
                </button>
              <% end %>
            </div>
            <div class="live-ui-tabs__content">
              <.tab_content tab={active_tab_descriptor(@children, active_tab(@props, @children))} />
            </div>
          </section>
        <% "tree_node" -> %>
          <li id={@id} class={@classes}>
            <button
              type="button"
              class={["live-ui-tree__node", if(Helpers.truthy?(Map.get(@props, "selected", false)), do: "is-selected")]}
              aria-expanded={if(Helpers.truthy?(Map.get(@props, "expanded", false)), do: "true", else: "false")}
              {Helpers.event_attrs(
                "click",
                nil,
                @descriptor,
                @tree_binding,
                %{
                  "expanded" => Helpers.truthy?(Map.get(@props, "expanded", false)),
                  "node_id" => @id
                }
              )}
            >
              <%= Map.get(@props, "label", @id) %>
            </button>
            <%= if Helpers.truthy?(Map.get(@props, "expanded", false)) and @children != [] do %>
              <ul><%= for child <- @children do %><LiveUi.WidgetRegistry.render descriptor={child} /><% end %></ul>
            <% end %>
          </li>
        <% "tree_view" -> %>
          <section id={@id} class={@classes} style={@style}><ul><%= for child <- @children do %><LiveUi.WidgetRegistry.render descriptor={child} /><% end %></ul></section>
        <% "command" -> %>
          <button id={@id} type="button" class={@classes} {@command_attrs}><%= Map.get(@props, "label", "Command") %></button>
        <% "command_palette" -> %>
          <section
            id={@id}
            class={[@classes, if(Helpers.truthy?(Map.get(@props, "open", true)), do: "is-open", else: "is-closed")]}
            style={@style}
            data-live-ui-hook={@hook}
            data-open={if(Helpers.truthy?(Map.get(@props, "open", true)), do: "true", else: "false")}
            {@palette_hook_attrs}
          >
            <form class="live-ui-command-palette__form" {@palette_form_attrs}>
              <input
                type="search"
                name="query"
                value={Map.get(@props, "query", "")}
                placeholder={Map.get(@props, "placeholder", "Search commands")}
              />
            </form>
            <ul data-active-command-id={Map.get(@props, "active_command_id")}>
              <%= for child <- @children do %><LiveUi.WidgetRegistry.render descriptor={child} /><% end %></ul>
          </section>
      <% end %>
    <% end %>
    """
  end

  def menu(assigns), do: direct_list_container(assigns, "menu")
  def context_menu(assigns), do: direct_list_container(assigns, "context_menu")
  def tree_view(assigns), do: direct_list_container(assigns, "tree_view")
  def command(assigns), do: direct_leaf(assigns, "command", ["disabled", "label", "text"])
  def tab(assigns), do: direct_leaf(assigns, "tab", ["disabled", "label", "text"])

  def menu_item(assigns) do
    descriptor =
      Helpers.direct_descriptor(assigns, "menu_item", %{
        "disabled" => Map.get(assigns, :disabled, Map.get(assigns, "disabled")),
        "label" => Map.get(assigns, :label, Map.get(assigns, "label"))
      })

    assigns =
      assigns
      |> assign(:descriptor, descriptor)
      |> assign(:id, Helpers.id(descriptor))
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-navigation", "live-ui-navigation--menu_item"])
      )
      |> assign(
        :menu_item_attrs,
        Helpers.event_attrs("click", descriptor, action_binding(descriptor))
      )
      |> assign_new(:inner_block, fn -> [] end)

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <li id={@id} class={@classes}>
        <button
          type="button"
          disabled={Helpers.truthy?(Map.get(Helpers.props(@descriptor), "disabled", false))}
          {@menu_item_attrs}
        >
          <%= Map.get(Helpers.props(@descriptor), "label", "Item") %>
        </button>
        <%= if @inner_block != [] do %>
          <ul><%= render_slot(@inner_block) %></ul>
        <% end %>
      </li>
    <% end %>
    """
  end

  def tree_node(assigns) do
    descriptor =
      Helpers.direct_descriptor(assigns, "tree_node", %{
        "disabled" => Map.get(assigns, :disabled, Map.get(assigns, "disabled")),
        "expanded" => Map.get(assigns, :expanded, Map.get(assigns, "expanded")),
        "label" => Map.get(assigns, :label, Map.get(assigns, "label")),
        "selected" => Map.get(assigns, :selected, Map.get(assigns, "selected"))
      })

    props = Helpers.props(descriptor)
    tree_binding = Helpers.binding(descriptor, ["on_select", "on_toggle"])

    assigns =
      assigns
      |> assign(:descriptor, descriptor)
      |> assign(:id, Helpers.id(descriptor))
      |> assign(:props, props)
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-navigation", "live-ui-navigation--tree_node"])
      )
      |> assign(:tree_attrs, tree_node_attrs(descriptor, tree_binding))
      |> assign_new(:inner_block, fn -> [] end)

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <li id={@id} class={@classes}>
        <button
          type="button"
          class={["live-ui-tree__node", if(Helpers.truthy?(Map.get(@props, "selected", false)), do: "is-selected")]}
          aria-expanded={if(Helpers.truthy?(Map.get(@props, "expanded", false)), do: "true", else: "false")}
          {@tree_attrs}
        >
          <%= Map.get(@props, "label", @id) %>
        </button>
        <%= if Helpers.truthy?(Map.get(@props, "expanded", false)) and @inner_block != [] do %>
          <ul><%= render_slot(@inner_block) %></ul>
        <% end %>
      </li>
    <% end %>
    """
  end

  def command_palette(assigns) do
    descriptor =
      Helpers.direct_descriptor(assigns, "command_palette", %{
        "active_command_id" =>
          Map.get(assigns, :active_command_id, Map.get(assigns, "active_command_id")),
        "open" => Map.get(assigns, :open, Map.get(assigns, "open")),
        "placeholder" => Map.get(assigns, :placeholder, Map.get(assigns, "placeholder")),
        "query" => Map.get(assigns, :query, Map.get(assigns, "query"))
      })

    props = Helpers.props(descriptor)

    assigns =
      assigns
      |> assign(:descriptor, descriptor)
      |> assign(:id, Helpers.id(descriptor))
      |> assign(:props, props)
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-navigation", "live-ui-navigation--command_palette"])
      )
      |> assign(:style, Helpers.inline_style(descriptor))
      |> assign(:hook, Helpers.hook_name(descriptor))
      |> assign(
        :palette_form_attrs,
        Helpers.merge_attrs([
          Helpers.event_attrs("change", descriptor, Helpers.binding(descriptor, "on_change")),
          Helpers.event_attrs(
            "submit",
            descriptor,
            Helpers.binding(descriptor, ["on_submit", "action"])
          )
        ])
      )
      |> assign(
        :palette_hook_attrs,
        Helpers.hook_event_attrs(
          "change",
          descriptor,
          Helpers.binding(descriptor, "on_change"),
          %{
            "active_command_id" => Map.get(props, "active_command_id"),
            "open" => Map.get(props, "open", true)
          }
        )
      )
      |> assign_new(:inner_block, fn -> [] end)

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <section
        id={@id}
        class={[@classes, if(Helpers.truthy?(Map.get(@props, "open", true)), do: "is-open", else: "is-closed")]}
        style={@style}
        data-live-ui-hook={@hook}
        data-open={if(Helpers.truthy?(Map.get(@props, "open", true)), do: "true", else: "false")}
        {@palette_hook_attrs}
      >
        <form class="live-ui-command-palette__form" {@palette_form_attrs}>
          <input
            type="search"
            name="query"
            value={Map.get(@props, "query", "")}
            placeholder={Map.get(@props, "placeholder", "Search commands")}
          />
        </form>
        <ul data-active-command-id={Map.get(@props, "active_command_id")}>
          <%= render_slot(@inner_block) %>
        </ul>
      </section>
    <% end %>
    """
  end

  def tabs(assigns) do
    descriptor =
      Helpers.direct_descriptor(assigns, "tabs", %{
        "active_tab" => Map.get(assigns, :active_tab, Map.get(assigns, "active_tab"))
      })

    props = Helpers.props(descriptor)
    tabs = Map.get(assigns, :tab, [])

    assigns =
      assigns
      |> assign(:descriptor, descriptor)
      |> assign(:id, Helpers.id(descriptor))
      |> assign(:props, props)
      |> assign(:tabs, tabs)
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-navigation", "live-ui-navigation--tabs"])
      )
      |> assign(:style, Helpers.inline_style(descriptor))

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <section id={@id} class={@classes} style={@style}>
        <div class="live-ui-tabs__bar">
          <%= for {tab, index} <- Enum.with_index(@tabs) do %>
            <% tab_id = tab[:id] || Integer.to_string(index) %>
            <% tab_label = tab[:label] || tab_id %>
            <% tab_disabled = Helpers.truthy?(tab[:disabled]) %>
            <% tab_attrs =
              Helpers.event_attrs(
                "click",
                nil,
                @descriptor,
                Helpers.binding(@descriptor, "on_change"),
                %{"tab_id" => tab_id}
              ) %>
            <button
              type="button"
              class={["live-ui-tabs__tab", if(tab_id == direct_active_tab(@props, @tabs), do: "is-active")]}
              disabled={tab_disabled}
              {tab_attrs ++ [{"phx-value-event_click_tab_index", to_string(index)}]}
            >
              <%= tab_label %>
            </button>
          <% end %>
        </div>
        <div class="live-ui-tabs__content">
          <%= if active_tab = direct_active_slot(@props, @tabs) do %>
            <%= render_slot(active_tab) %>
          <% end %>
        </div>
      </section>
    <% end %>
    """
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

  defp direct_list_container(assigns, kind) do
    descriptor = Helpers.direct_descriptor(assigns, kind)

    assigns =
      assigns
      |> assign(:descriptor, descriptor)
      |> assign(:id, Helpers.id(descriptor))
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-navigation", "live-ui-navigation--#{kind}"])
      )
      |> assign(:style, Helpers.inline_style(descriptor))
      |> assign_new(:inner_block, fn -> [] end)

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <%= case @descriptor.kind do %>
        <% "menu" -> %>
          <nav id={@id} class={@classes} style={@style}><ul><%= render_slot(@inner_block) %></ul></nav>
        <% "context_menu" -> %>
          <div id={@id} class={@classes} style={@style}><ul><%= render_slot(@inner_block) %></ul></div>
        <% "tree_view" -> %>
          <section id={@id} class={@classes} style={@style}><ul><%= render_slot(@inner_block) %></ul></section>
      <% end %>
    <% end %>
    """
  end

  defp tab_content(assigns) do
    assigns =
      assigns
      |> assign(:children, if(assigns.tab, do: Helpers.children(assigns.tab), else: []))

    ~H"""
    <%= for child <- @children do %>
      <LiveUi.WidgetRegistry.render descriptor={child} />
    <% end %>
    """
  end

  defp active_tab(props, children) do
    Map.get(props, "active_tab") ||
      children
      |> List.first()
      |> case do
        nil -> nil
        child -> Helpers.id(child)
      end
  end

  defp active_tab_descriptor(children, active_id) do
    Enum.find(children, fn child -> Helpers.id(child) == active_id end)
  end

  defp direct_active_tab(props, tabs) do
    Map.get(props, "active_tab") ||
      tabs
      |> List.first()
      |> case do
        nil -> nil
        tab -> tab[:id]
      end
  end

  defp direct_active_slot(props, tabs) do
    active_id = direct_active_tab(props, tabs)
    Enum.find(tabs, fn tab -> tab[:id] == active_id end)
  end

  defp tab_index(tab, children) do
    Enum.find_index(children, fn child -> Helpers.id(child) == Helpers.id(tab) end) || 0
  end

  defp tree_node_attrs(descriptor, tree_binding) do
    Helpers.event_attrs(
      "click",
      nil,
      descriptor,
      tree_binding,
      %{
        "expanded" => Helpers.truthy?(Helpers.props(descriptor)["expanded"]),
        "node_id" => Helpers.id(descriptor)
      }
    )
  end

  defp action_binding(descriptor), do: Helpers.binding(descriptor, ["action", "on_select"])
end
