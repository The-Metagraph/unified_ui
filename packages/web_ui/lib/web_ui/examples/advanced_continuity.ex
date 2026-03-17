defmodule WebUi.Examples.AdvancedContinuity do
  @moduledoc """
  Comparison artifact for native and canonical advanced `web_ui` behavior.
  """

  alias WebUi.Examples.{CanonicalAdvancedOperationsScreen, NativeAdvancedOperationsScreen}

  @display_kinds [:grid, :stack, :viewport, :scroll_bar, :split_pane]
  @layer_kinds [:overlay, :dialog, :toast, :alert_dialog, :context_menu]

  @spec compare() :: map()
  def compare do
    {:ok, native_state} = WebUi.Server.mount(NativeAdvancedOperationsScreen)
    {:ok, canonical_state} = CanonicalAdvancedOperationsScreen.render_view_state()

    native = snapshot(native_state.view_state)
    canonical = snapshot(canonical_state)

    %{
      native: native,
      canonical: canonical,
      continuity: %{
        widget_kinds_match?: native.widget_kinds == canonical.widget_kinds,
        render_tags_match?: native.render_tags == canonical.render_tags,
        display_kinds_match?: native.display_kinds == canonical.display_kinds,
        layer_kinds_match?: native.layer_kinds == canonical.layer_kinds,
        shared_ids:
          native.widget_ids
          |> Enum.filter(&(&1 in canonical.widget_ids))
          |> Enum.uniq()
          |> Enum.sort()
      }
    }
  end

  def metadata do
    %{
      id: :advanced_continuity,
      compares: [:native_advanced_operations, :canonical_advanced_operations],
      summary: "Continuity report for advanced native and canonical examples."
    }
  end

  defp snapshot(view_state) do
    %{
      screen: view_state.screen,
      widget_ids: collect_widget_ids(view_state.widgets),
      widget_kinds: collect_widget_kinds(view_state.widgets),
      display_kinds: collect_filtered_kinds(view_state.widgets, @display_kinds),
      layer_kinds: collect_filtered_kinds(view_state.widgets, @layer_kinds),
      render_tags: collect_render_tags(view_state.render_tree)
    }
  end

  defp collect_widget_ids([]), do: []

  defp collect_widget_ids(widgets) do
    widgets
    |> Enum.flat_map(fn widget ->
      [to_string(widget.id)] ++
        (widget.slots
         |> Map.values()
         |> List.flatten()
         |> collect_widget_ids())
    end)
  end

  defp collect_widget_kinds([]), do: []

  defp collect_widget_kinds(widgets) do
    widgets
    |> Enum.flat_map(fn widget ->
      [widget.kind] ++
        (widget.slots
         |> Map.values()
         |> List.flatten()
         |> collect_widget_kinds())
    end)
  end

  defp collect_filtered_kinds(widgets, allowed) do
    widgets
    |> collect_widget_kinds()
    |> Enum.filter(&(&1 in allowed))
  end

  defp collect_render_tags([]), do: []

  defp collect_render_tags(nodes) do
    nodes
    |> Enum.flat_map(fn node ->
      [node.dom.tag] ++
        (node.slots
         |> Enum.flat_map(& &1.children)
         |> collect_render_tags())
    end)
  end
end
