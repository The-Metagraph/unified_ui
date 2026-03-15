defmodule LiveUi.Layout.Grid do
  @moduledoc """
  Baseline grid layout primitive.
  """

  use LiveUi.Component, family: :layout, name: :grid, slots: [:inner_block]

  LiveUi.Component.common_attrs()
  attr(:columns, :integer, default: nil)
  attr(:rows, :integer, default: nil)
  attr(:gap, :string, default: nil)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id={@id}
      data-live-ui-widget="grid"
      data-live-ui-columns={@columns}
      data-live-ui-rows={@rows}
      data-live-ui-gap={@gap}
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
