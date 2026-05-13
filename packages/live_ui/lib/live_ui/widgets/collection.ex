defmodule LiveUi.Widgets.Collection do
  @moduledoc """
  Native collection widgets for repeated renderer-owned composition.
  """

  @spec modules() :: [module()]
  def modules do
    [LiveUi.Widgets.RepeatedCollection]
  end
end

defmodule LiveUi.Widgets.RepeatedCollection do
  @moduledoc """
  Native repeated collection wrapper with stable row identity metadata.
  """

  use LiveUi.Component,
    family: :collection,
    name: :repeated_collection,
    slots: [:row, :empty_state]

  LiveUi.Component.common_attrs()
  attr(:rows, :list, default: [])
  attr(:item_alias, :string, default: "item")
  attr(:index_alias, :string, default: "index")
  attr(:key_path, :list, default: [])
  slot(:row)
  slot(:empty_state)

  @impl true
  def render(assigns) do
    ~H"""
    <section
      id={@id}
      data-live-ui-widget="repeated-collection"
      data-live-ui-item-alias={@item_alias}
      data-live-ui-index-alias={@index_alias}
      data-live-ui-key-path={Enum.join(Enum.map(@key_path, &to_string/1), ".")}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      {@rest}
    >
      <%= if @rows == [] do %>
        <div data-live-ui-collection-slot="empty"><%= render_slot(@empty_state) %></div>
      <% else %>
        <div
          :for={row <- @rows}
          data-live-ui-collection-row={Map.get(row, :key)}
          data-live-ui-row-index={Map.get(row, :index)}
        ><%= render_slot(@row, row) %></div>
      <% end %>
    </section>
    """
  end
end
