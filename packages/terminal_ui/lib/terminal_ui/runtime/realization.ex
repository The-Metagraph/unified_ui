defmodule TerminalUi.Runtime.Realization do
  @moduledoc """
  Shared foundational realization for direct-native and canonical widget trees.
  """

  alias TerminalUi.Runtime.{Error, Screen}
  alias TerminalUi.Widget

  @type realized_node :: map()

  @spec realize_screen(Screen.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def realize_screen(%Screen{} = screen, opts \\ []) do
    with {:ok, tree} <- realize_widget(screen.root, [screen.id], opts) do
      focus_order = collect_focus_order(tree)

      {:ok,
       %{
         screen_id: screen.id,
         tree: tree,
         focus_order: focus_order,
         current_focus: List.first(focus_order),
         binding_index: collect_binding_index(tree),
         event_targets: collect_event_targets(tree),
         cell_surface: to_cell_surface(tree),
         validation_state: :foundational_ready,
         diagnostics: %{
           source_kind: screen.source_kind,
           backend_mode: screen.backend_mode,
           shared_runtime: true,
           layout: screen.layout
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
    if widget.kind in TerminalUi.Widgets.kinds() do
      widget.children
      |> Enum.with_index()
      |> Enum.reduce_while({:ok, []}, fn {child, index}, {:ok, acc} ->
        case realize_widget(child, path ++ ["#{widget.id}:#{index}"], opts) do
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
             label: Map.get(widget.metadata, :label),
             path: path,
             focusable:
               Map.get(widget.metadata, :focusable, false) &&
                 !Map.get(widget.state, :disabled, false),
             disabled: Map.get(widget.state, :disabled, false),
             bindings: widget.bindings,
             events: Map.keys(widget.events),
             attributes: widget.attributes,
             styles: widget.styles,
             children: children,
             render_mode: Keyword.get(opts, :render_mode, :foundational_terminal)
           }}

        {:error, error} ->
          {:error, error}
      end
    else
      {:error,
       Error.new(
         :unsupported_foundational_widget,
         %{kind: widget.kind, widget_id: normalize_id(widget.id)},
         :realization
       )}
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
      Enum.reduce(current.bindings, acc, fn {slot, binding_name}, index ->
        Map.update(index, binding_name, [%{widget_id: current.id, slot: slot}], fn entries ->
          entries ++ [%{widget_id: current.id, slot: slot}]
        end)
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
        content:
          current.attributes[:content] || current.attributes[:label] || current.label ||
            to_string(current.kind),
        kind: current.kind,
        family: current.family
      }
    end)
  end

  defp flatten_nodes(node, acc) do
    Enum.reduce(node.children, acc ++ [node], &flatten_nodes(&1, &2))
  end

  defp normalize_id(nil), do: "anonymous"
  defp normalize_id(id), do: to_string(id)
end
