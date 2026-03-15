defmodule LiveUi.Widgets.Canvas do
  @moduledoc """
  Native canvas primitive for positioned drawing operations.
  """

  use LiveUi.Component, family: :display, name: :canvas, events: [:change]

  LiveUi.Component.common_attrs()
  attr(:operations, :list, default: [])
  attr(:width, :integer, default: nil)
  attr(:height, :integer, default: nil)
  attr(:unit, :string, default: "cell")
  attr(:background, :string, default: nil)
  attr(:clip, :boolean, default: true)

  @impl true
  def render(assigns) do
    ~H"""
    <section
      id={@id}
      data-live-ui-widget="canvas"
      data-live-ui-width={@width}
      data-live-ui-height={@height}
      data-live-ui-unit={@unit}
      data-live-ui-background={@background}
      data-live-ui-clip={@clip}
      data-live-ui-operation-count={length(@operations)}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <%= for operation <- @operations do %>
        <div
          data-live-ui-canvas-op={operation[:kind] || operation["kind"]}
          data-live-ui-canvas-x={coord(operation, :position, :x)}
          data-live-ui-canvas-y={coord(operation, :position, :y)}
        >
          <%= operation[:text] || operation["text"] %>
        </div>
      <% end %>
    </section>
    """
  end

  defp coord(operation, key, axis) do
    operation
    |> fetch_map(key)
    |> case do
      nil -> nil
      map -> Map.get(map, axis) || Map.get(map, Atom.to_string(axis))
    end
  end

  defp fetch_map(operation, key) do
    Map.get(operation, key) || Map.get(operation, Atom.to_string(key))
  end
end
