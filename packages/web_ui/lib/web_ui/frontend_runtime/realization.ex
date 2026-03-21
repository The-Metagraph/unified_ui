defmodule WebUi.FrontendRuntime.Realization do
  @moduledoc """
  Frontend-side realization of server-authored render trees into browser-facing
  node descriptions.
  """

  @spec realize(map(), map()) :: map()
  def realize(render_tree, local_state \\ %{}) when is_map(render_tree) and is_map(local_state) do
    %{
      id: render_tree.id,
      family: render_tree.family,
      kind: render_tree.kind,
      tag: render_tree.dom.tag,
      role: render_tree.dom.role,
      attrs: render_tree.dom.attributes,
      attributes: render_tree.attributes,
      state: render_tree.state,
      styles: render_tree.styles,
      browser: %{
        interactive?: render_tree.interactions.interactive?,
        focusable?: render_tree.interactions.focusable?,
        editable?: render_tree.interactions.editable?,
        navigable?: render_tree.interactions.navigable?,
        focused?: Map.get(local_state, :focused_id) == render_tree.id,
        editing?: editing?(local_state, render_tree.id, render_tree.state)
      },
      slots:
        Enum.map(render_tree.slots, fn slot ->
          %{
            name: slot.name,
            children: Enum.map(slot.children, &realize(&1, local_state))
          }
        end)
    }
  end

  defp editing?(local_state, id, state) do
    editing_ids = Map.get(local_state, :editing_ids, [])
    id in List.wrap(editing_ids) or Map.get(state, :editing, false)
  end
end
