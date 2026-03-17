defmodule WebUi.Frontend.Realization do
  @moduledoc """
  Frontend-side realization of server-authored render trees into browser-facing
  node descriptions.
  """

  @spec realize([map()], map()) :: [map()]
  def realize(render_tree, local_state \\ %{})
      when is_list(render_tree) and is_map(local_state) do
    Enum.map(render_tree, &realize_node(&1, local_state))
  end

  defp realize_node(node, local_state) do
    %{
      id: node.id,
      family: node.family,
      kind: node.kind,
      tag: node.dom.tag,
      role: node.dom.role,
      attrs: node.dom.attributes,
      props: node.props,
      browser: %{
        interactive?: node.interactions.interactive?,
        focusable?: node.interactions.focusable?,
        editable?: node.interactions.editable?,
        focused?: local_state[:focused_widget] == node.id,
        editing?: editing?(local_state, node.id, node.state)
      },
      slots:
        Enum.map(node.slots, fn slot ->
          %{
            name: slot.name,
            children: Enum.map(slot.children, &realize_node(&1, local_state))
          }
        end)
    }
  end

  defp editing?(local_state, id, state) do
    editing_widgets = Map.get(local_state, :editing_widgets, [])

    id in List.wrap(editing_widgets) or Map.get(state, :editing?, false)
  end
end
