defmodule LiveUi.Widgets.Viewport do
  @moduledoc """
  Native viewport primitive for clipped and scrollable regions.
  """

  use LiveUi.Component, family: :display, name: :viewport, slots: [:inner_block]

  LiveUi.Component.common_attrs()
  attr(:axis, :string, default: "vertical")
  attr(:offset_x, :integer, default: 0)
  attr(:offset_y, :integer, default: 0)
  attr(:clip, :boolean, default: true)
  attr(:scrollbars, :string, default: "auto")
  attr(:width, :string, default: nil)
  attr(:height, :string, default: nil)
  attr(:sync_group, :string, default: nil)
  attr(:independent_scroll, :boolean, default: false)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    ~H"""
    <section
      id={@id}
      data-live-ui-widget="viewport"
      data-live-ui-axis={@axis}
      data-live-ui-offset-x={@offset_x}
      data-live-ui-offset-y={@offset_y}
      data-live-ui-clip={@clip}
      data-live-ui-scrollbars={@scrollbars}
      data-live-ui-width={@width}
      data-live-ui-height={@height}
      data-live-ui-sync-group={@sync_group}
      data-live-ui-independent-scroll={@independent_scroll}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <div data-live-ui-viewport-slot="content"><%= render_slot(@inner_block) %></div>
    </section>
    """
  end
end
