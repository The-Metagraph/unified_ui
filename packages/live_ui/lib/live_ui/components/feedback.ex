defmodule LiveUi.Components.Feedback do
  @moduledoc false

  use Phoenix.Component

  alias LiveUi.Components.Helpers

  attr(:descriptor, :map, required: true)

  def render(assigns) do
    descriptor = assigns.descriptor
    props = Helpers.props(descriptor)
    children = Helpers.children(descriptor)
    kind = Helpers.kind(descriptor)

    {content_children, action_children} =
      Enum.split_with(children, &(Helpers.kind(&1) != "dialog_button"))

    assigns =
      assigns
      |> assign(:id, Helpers.id(descriptor))
      |> assign(:kind, kind)
      |> assign(:props, props)
      |> assign(:content_children, content_children)
      |> assign(:action_children, action_children)
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-feedback", "live-ui-feedback--#{kind}"])
      )
      |> assign(:style, Helpers.inline_style(descriptor))
      |> assign(
        :dialog_button_attrs,
        Helpers.event_attrs("click", descriptor, button_binding(descriptor))
      )
      |> assign(
        :confirm_attrs,
        Helpers.event_attrs("click", descriptor, Helpers.binding(descriptor, "on_confirm"))
      )
      |> assign(
        :cancel_attrs,
        Helpers.event_attrs("click", descriptor, Helpers.binding(descriptor, "on_cancel"))
      )

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <%= case @kind do %>
        <% "dialog_button" -> %>
          <button id={@id} type="button" class={@classes} {@dialog_button_attrs}>
            <%= Map.get(@props, "label", "Action") %>
          </button>
        <% "dialog" -> %>
          <aside id={@id} class={@classes} style={@style} role="dialog" aria-modal={Helpers.truthy?(Map.get(@props, "modal", true))}>
            <header><h2><%= Map.get(@props, "title", "Dialog") %></h2></header>
            <div class="live-ui-dialog__content"><%= for child <- @content_children do %><LiveUi.WidgetRegistry.render descriptor={child} /><% end %></div>
            <footer><%= for child <- @action_children do %><LiveUi.WidgetRegistry.render descriptor={child} /><% end %></footer>
          </aside>
        <% "alert_dialog" -> %>
          <aside id={@id} class={@classes} style={@style} role="alertdialog">
            <header><h2><%= Map.get(@props, "title", "Alert") %></h2></header>
            <p><%= Map.get(@props, "message", "") %></p>
            <div class="live-ui-alert__actions">
              <button type="button" {@confirm_attrs}>Confirm</button>
              <button type="button" {@cancel_attrs}>Cancel</button>
            </div>
          </aside>
        <% "toast" -> %>
          <aside id={@id} class={@classes} style={@style} role="status">
            <p><%= Map.get(@props, "message", "") %></p>
          </aside>
      <% end %>
    <% end %>
    """
  end

  def dialog_button(assigns), do: direct_leaf(assigns, "dialog_button", ["label"])

  def dialog(assigns) do
    descriptor =
      Helpers.direct_descriptor(assigns, "dialog", %{
        "modal" => Map.get(assigns, :modal, Map.get(assigns, "modal")),
        "title" => Map.get(assigns, :title, Map.get(assigns, "title"))
      })

    assigns =
      assigns
      |> assign(:descriptor, descriptor)
      |> assign(:id, Helpers.id(descriptor))
      |> assign(
        :classes,
        Helpers.classes(descriptor, ["live-ui-feedback", "live-ui-feedback--dialog"])
      )
      |> assign(:style, Helpers.inline_style(descriptor))
      |> assign_new(:inner_block, fn -> [] end)
      |> assign_new(:action, fn -> [] end)

    ~H"""
    <%= if Helpers.visible?(@descriptor) do %>
      <aside
        id={@id}
        class={@classes}
        style={@style}
        role="dialog"
        aria-modal={Helpers.truthy?(Map.get(Helpers.props(@descriptor), "modal", true))}
      >
        <header><h2><%= Map.get(Helpers.props(@descriptor), "title", "Dialog") %></h2></header>
        <div class="live-ui-dialog__content"><%= render_slot(@inner_block) %></div>
        <footer><%= for action <- @action do %><%= render_slot(action) %><% end %></footer>
      </aside>
    <% end %>
    """
  end

  def alert_dialog(assigns) do
    direct_leaf(assigns, "alert_dialog", ["message", "title"])
  end

  def toast(assigns), do: direct_leaf(assigns, "toast", ["message"])

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

  defp button_binding(descriptor), do: Helpers.binding(descriptor, "action")
end
