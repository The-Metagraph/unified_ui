defmodule LiveUi.Widgets.Tabs do
  @moduledoc """
  Baseline native tabs widget.
  """

  use LiveUi.Component, family: :navigation, name: :tabs, events: [:click]

  LiveUi.Component.common_attrs()
  attr(:items, :list, default: [])
  attr(:active_item, :string, default: nil)

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      data-live-ui-widget="tabs"
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <div role="tablist">
        <%= for item <- @items do %>
          <button
            type="button"
            role="tab"
            aria-selected={if to_string(item[:id]) == @active_item, do: "true", else: "false"}
            disabled={item[:disabled]}
            data-item-id={item[:id]}
          ><%= item[:label] %></button>
        <% end %>
      </div>
    </div>
    """
  end
end
