defmodule DesktopUi.Runtime.Realization do
  @moduledoc """
  Shared foundational realization for native and canonical `desktop_ui` screens.
  """

  alias DesktopUi.Runtime.{Error, Screen}
  alias DesktopUi.Widget

  @layout_kinds [:column, :content, :dialog, :row, :stack, :window]

  @type realized_node :: map()

  @spec realize_screen(Screen.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def realize_screen(%Screen{} = screen, opts \\ []) do
    with {:ok, tree} <- realize_widget(screen.root, [screen.id], opts) do
      focus_order = collect_focus_order(tree)
      binding_index = collect_binding_index(tree)

      {:ok,
       %{
         screen_id: screen.id,
         tree: tree,
         focus_order: focus_order,
         current_focus: List.first(focus_order),
         binding_index: binding_index,
         event_targets: collect_event_targets(tree),
         cell_surface: to_cell_surface(tree),
         validation_state: :foundational_ready,
         diagnostics: %{
           source_kind: screen.source_kind,
           shared_runtime: true,
           root_kind: screen.root.kind,
           layout_kinds: screen.composition.layout_kinds,
           widget_count: screen.composition.widget_count,
           binding_names: Map.keys(binding_index),
           focus_traversal: :ready,
           event_targeting: :ready,
           layout_guards: :ready,
           invalid_layout_state: nil
         }
       }}
    end
  end

  @spec focus_state(map()) :: map()
  def focus_state(realization) when is_map(realization) do
    %{
      current: Map.get(realization, :current_focus),
      order: Map.get(realization, :focus_order, [])
    }
  end

  defp realize_widget(%Widget{} = widget, path, opts) do
    cond do
      widget.kind not in supported_kinds() ->
        {:error,
         Error.new(
           :unsupported_foundational_widget,
           %{kind: widget.kind, widget_id: normalize_id(widget.id)},
           :realization
         )}

      invalid_layout_state?(widget) ->
        {:error,
         Error.new(
           :invalid_layout_state,
           %{kind: widget.kind, widget_id: normalize_id(widget.id)},
           :realization
         )}

      true ->
        widget.children
        |> Enum.with_index()
        |> Enum.reduce_while({:ok, []}, fn {child, index}, {:ok, acc} ->
          case realize_widget(child, path ++ ["#{normalize_id(widget.id)}:#{index}"], opts) do
            {:ok, realized_child} -> {:cont, {:ok, acc ++ [realized_child]}}
            {:error, reason} -> {:halt, {:error, reason}}
          end
        end)
        |> case do
          {:ok, children} ->
            {:ok,
             %{
               id: normalize_id(widget.id),
               kind: widget.kind,
               family: widget.family,
               path: path,
               focusable:
                 Map.get(widget.metadata, :focusable, false) &&
                   !Map.get(widget.state, :disabled, false),
               disabled: Map.get(widget.state, :disabled, false),
               bindings: widget.bindings,
               events: Map.keys(widget.events),
               metadata: widget.metadata,
               state: widget.state,
               attributes: widget.attributes,
               styles: widget.styles,
               layout?: widget.kind in @layout_kinds,
               children: children,
               render_target: Keyword.get(opts, :render_target, :shared_desktop_runtime)
             }}

          {:error, error} ->
            {:error, error}
        end
    end
  end

  defp collect_focus_order(node) do
    node
    |> flatten_nodes([])
    |> Enum.filter(& &1.focusable)
    |> Enum.map(& &1.id)
  end

  defp collect_binding_index(node) do
    Enum.reduce(flatten_nodes(node, []), %{}, fn current, acc ->
      Enum.reduce(current.bindings, acc, fn {_slot, binding_name}, index ->
        if is_nil(binding_name) do
          index
        else
          Map.update(index, binding_name, [%{widget_id: current.id}], fn entries ->
            entries ++ [%{widget_id: current.id}]
          end)
        end
      end)
    end)
  end

  defp collect_event_targets(node) do
    flatten_nodes(node, [])
    |> Enum.filter(&(length(&1.events) > 0))
    |> Map.new(fn current -> {current.id, current.events} end)
  end

  defp to_cell_surface(node) do
    flatten_nodes(node, [])
    |> Enum.map(fn current ->
      %{
        widget_id: current.id,
        kind: current.kind,
        family: current.family,
        content:
          current.attributes[:content] || current.attributes[:label] ||
            current.attributes[:window_title] || to_string(current.kind)
      }
    end)
  end

  defp flatten_nodes(node, acc) do
    Enum.reduce(node.children, acc ++ [node], &flatten_nodes(&1, &2))
  end

  defp supported_kinds do
    DesktopUi.Widgets.kinds()
  end

  defp invalid_layout_state?(widget) do
    widget.kind in [:column, :content, :row, :stack, :window, :dialog] and
      !is_list(widget.children)
  end

  defp normalize_id(nil), do: "anonymous"
  defp normalize_id(id), do: to_string(id)
end
