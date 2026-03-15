defmodule LiveUi.Widgets.AlertDialog do
  @moduledoc """
  Native alert-dialog widget for destructive or attention-demanding flows.
  """

  use LiveUi.Component, family: :overlay, name: :alert_dialog, slots: [:inner_block, :actions]

  LiveUi.Component.common_attrs()
  attr(:title, :string, default: nil)
  attr(:severity, :string, default: "warning")
  attr(:open, :boolean, default: true)
  attr(:requires_confirmation, :boolean, default: true)
  attr(:background_fill, :string, default: "scrim")
  slot(:inner_block)
  slot(:actions)

  @impl true
  def render(assigns) do
    ~H"""
    <section
      id={@id}
      data-live-ui-widget="alert-dialog"
      data-live-ui-open={@open}
      data-live-ui-severity={@severity}
      data-live-ui-requires-confirmation={@requires_confirmation}
      data-live-ui-background-fill={@background_fill}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <div data-live-ui-alert-slot="header">
        <%= if @title do %>
          <h2><%= @title %></h2>
        <% end %>
      </div>
      <div data-live-ui-alert-slot="content"><%= render_slot(@inner_block) %></div>
      <%= if @actions != [] do %>
        <footer data-live-ui-alert-slot="actions"><%= render_slot(@actions) %></footer>
      <% end %>
    </section>
    """
  end
end
