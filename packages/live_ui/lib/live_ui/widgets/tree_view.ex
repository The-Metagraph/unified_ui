defmodule LiveUi.Widgets.TreeView do
  @moduledoc """
  Native tree-view widget for hierarchical data.
  """

  use LiveUi.Component, family: :data, name: :tree_view, events: [:click, :selection]

  LiveUi.Component.common_attrs()
  attr(:nodes, :list, default: [])
  attr(:selection_mode, :string, default: "single")

  @impl true
  def render(assigns) do
    ~H"""
    <section
      id={@id}
      data-live-ui-widget="tree-view"
      data-live-ui-selection-mode={@selection_mode}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <ul>
        <%= for node <- @nodes do %>
          <.tree_node node={node} />
        <% end %>
      </ul>
    </section>
    """
  end

  attr(:node, :map, required: true)

  defp tree_node(assigns) do
    ~H"""
    <li data-node-id={@node[:id]} data-selected={@node[:selected]} data-expanded={@node[:expanded]}>
      <span><%= @node[:label] || @node[:value] %></span>
      <%= if @node[:children] do %>
        <ul>
          <%= for child <- @node[:children] do %>
            <.tree_node node={child} />
          <% end %>
        </ul>
      <% end %>
    </li>
    """
  end
end
