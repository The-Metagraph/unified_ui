defmodule LiveUi.Layout.Column do
  @moduledoc """
  Baseline vertical layout primitive.
  """

  use LiveUi.Component, family: :layout, name: :column, slots: [:inner_block]

  LiveUi.Component.common_attrs()
  attr(:gap, :string, default: nil)
  attr(:align, :string, default: nil)
  attr(:justify, :string, default: nil)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      data-live-ui-widget="column"
      data-live-ui-gap={@gap}
      data-live-ui-align={@align}
      data-live-ui-justify={@justify}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
