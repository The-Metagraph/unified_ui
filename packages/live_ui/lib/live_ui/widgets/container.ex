defmodule LiveUi.Widgets.Container do
  @moduledoc """
  Baseline native container widget for grouping child content.
  """

  use LiveUi.Component, family: :layout, name: :container, slots: [:inner_block]

  LiveUi.Component.common_attrs()
  slot(:inner_block)

  @impl true
  def render(assigns) do
    ~H"""
    <section id={@id} data-live-ui-widget="container" class={@class} {@rest}>
      <%= render_slot(@inner_block) %>
    </section>
    """
  end
end
