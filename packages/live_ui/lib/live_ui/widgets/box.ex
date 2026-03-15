defmodule LiveUi.Widgets.Box do
  @moduledoc """
  Baseline panel-like container widget for foundational screen composition.
  """

  use LiveUi.Component, family: :layout, name: :box, slots: [:inner_block]

  LiveUi.Component.common_attrs()
  attr(:padding, :string, default: nil)
  attr(:border, :string, default: nil)
  attr(:background, :string, default: nil)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    ~H"""
    <section
      id={@id}
      data-live-ui-widget="box"
      data-live-ui-padding={@padding}
      data-live-ui-border={@border}
      data-live-ui-background={@background}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </section>
    """
  end
end
