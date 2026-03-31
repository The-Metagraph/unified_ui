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
            aria-selected={if to_string(fetch(item, :id)) == @active_item, do: "true", else: "false"}
            disabled={fetch(item, :disabled) || fetch(item, :disabled?)}
            data-item-id={fetch(item, :id)}
          ><%= fetch(item, :label) %></button>
        <% end %>
      </div>
    </div>
    """
  end

  defp fetch(item, key) when is_map(item) do
    Map.get(item, key) || Map.get(item, Atom.to_string(key))
  end
end
