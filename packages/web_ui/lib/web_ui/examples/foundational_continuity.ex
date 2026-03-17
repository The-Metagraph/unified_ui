defmodule WebUi.Examples.FoundationalContinuity do
  @moduledoc """
  Comparison artifact for native and canonical foundational `web_ui` behavior.
  """

  alias WebUi.Examples.{CanonicalFoundationalScreen, NativeFoundationalScreen}

  @spec compare() :: map()
  def compare do
    {:ok, native_state} = WebUi.Server.mount(NativeFoundationalScreen)
    {:ok, canonical_state} = CanonicalFoundationalScreen.render_view_state()

    native = snapshot(native_state.view_state)
    canonical = snapshot(canonical_state)

    %{
      native: native,
      canonical: canonical,
      continuity: %{
        widget_kinds_match?: native.widget_kinds == canonical.widget_kinds,
        render_tags_match?: native.render_tags == canonical.render_tags,
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
      id: :foundational_continuity,
      compares: [:native_foundational, :canonical_foundational],
      summary: "Continuity report for foundational native and canonical examples."
    }
  end

  defp snapshot(view_state) do
    %{
      screen: view_state.screen,
      widget_ids: collect_widget_ids(view_state.widgets),
      widget_kinds: collect_widget_kinds(view_state.widgets),
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
