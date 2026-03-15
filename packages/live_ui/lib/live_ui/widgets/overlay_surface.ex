defmodule LiveUi.Widgets.OverlaySurface do
  @moduledoc """
  Native overlay-surface widget that composes a base region with layered overlays.
  """

  use LiveUi.Component, family: :overlay, name: :overlay_surface, slots: [:base, :overlay]

  LiveUi.Component.common_attrs()
  attr(:mode, :string, default: "stacked")
  attr(:background_fill, :string, default: "transparent")
  attr(:dismissible, :boolean, default: false)
  attr(:focus_scope, :string, default: nil)
  slot(:base, required: true)
  slot(:overlay)

  @impl true
  def render(assigns) do
    ~H"""
    <section
      id={@id}
      data-live-ui-widget="overlay-surface"
      data-live-ui-mode={@mode}
      data-live-ui-background-fill={@background_fill}
      data-live-ui-dismissible={@dismissible}
      data-live-ui-focus-scope={@focus_scope}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <div data-live-ui-overlay-slot="base"><%= render_slot(@base) %></div>
      <%= for overlay <- @overlay do %>
        <div data-live-ui-overlay-slot="overlay"><%= render_slot([overlay]) %></div>
      <% end %>
    </section>
    """
  end
end
