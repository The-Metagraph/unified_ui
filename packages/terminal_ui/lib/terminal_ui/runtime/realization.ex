defmodule TerminalUi.Runtime.Realization do
  @moduledoc """
  Shared terminal realization for direct-native and canonical widget trees.
  """

  alias TerminalUi.{Capabilities, Layout, Layer}
  alias TerminalUi.Runtime.{Error, Screen}
  alias TerminalUi.Widget

  @type realized_node :: map()

  @spec realize_screen(Screen.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def realize_screen(%Screen{} = screen, opts \\ []) do
    opts = Keyword.put_new(opts, :backend_mode, screen.backend_mode)
    capability_diagnostics = Capabilities.diagnostics(backend_mode: screen.backend_mode)

    with {:ok, tree} <- realize_widget(screen.root, [screen.id], opts) do
      focus_order = collect_focus_order(tree)
      layers = collect_layers(tree)
      viewport_regions = collect_viewport_regions(tree)
      fallbacks = collect_fallbacks(tree)

      {:ok,
       %{
         screen_id: screen.id,
         tree: tree,
         focus_order: focus_order,
         current_focus: List.first(focus_order),
         binding_index: collect_binding_index(tree),
         event_targets: collect_event_targets(tree),
         cell_surface: to_cell_surface(tree),
         layers: layers,
         viewport_regions: viewport_regions,
         fallbacks: fallbacks,
         validation_state: validation_state_for(tree),
         diagnostics: %{
           source_kind: screen.source_kind,
           backend_mode: screen.backend_mode,
           shared_runtime: true,
           layout: screen.layout,
           capability_profile: capability_diagnostics.profile,
           capability_fallbacks: capability_diagnostics.fallback_modes,
           allowed_variation: capability_diagnostics.allowed_variation
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
    if widget.kind in allowed_kinds() do
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
             slots: widget.slots,
             focusable:
               Map.get(widget.metadata, :focusable, false) &&
                 !Map.get(widget.state, :disabled, false),
             disabled: Map.get(widget.state, :disabled, false),
             degradation: degradation_for(widget, opts),
             layer_role: layer_role_for(widget),
             viewport:
               widget.kind in Layout.kinds() &&
                 widget.kind in [:viewport, :scroll_region, :split_pane],
             positioned: widget.kind in [:canvas_surface, :positioned, :absolute],
             bindings: widget.bindings,
             events: Map.keys(widget.events),
             attributes: widget.attributes,
             styles: widget.styles,
             children: children,
             render_mode: Keyword.get(opts, :render_mode, :advanced_terminal)
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

  defp collect_layers(node) do
    flatten_nodes(node, [])
    |> Enum.filter(&(not is_nil(&1.layer_role)))
    |> Enum.map(fn current ->
      %{
        widget_id: current.id,
        kind: current.kind,
        role: current.layer_role,
        fallback: current.degradation
      }
    end)
  end

  defp collect_viewport_regions(node) do
    flatten_nodes(node, [])
    |> Enum.filter(&(&1.viewport || &1.positioned))
    |> Enum.map(fn current ->
      %{
        widget_id: current.id,
        kind: current.kind,
        viewport: current.viewport,
        positioned: current.positioned
      }
    end)
  end

  defp collect_fallbacks(node) do
    flatten_nodes(node, [])
    |> Enum.filter(&(not is_nil(&1.degradation)))
    |> Enum.map(fn current ->
      %{widget_id: current.id, kind: current.kind, fallback: current.degradation}
    end)
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

  defp validation_state_for(tree) do
    if collect_layers(tree) == [] and collect_viewport_regions(tree) == [] do
      :foundational_ready
    else
      :advanced_ready
    end
  end

  defp flatten_nodes(node, acc) do
    Enum.reduce(node.children, acc ++ [node], &flatten_nodes(&1, &2))
  end

  defp allowed_kinds do
    TerminalUi.Widgets.kinds() ++ Layout.kinds() ++ Layer.kinds()
  end

  defp degradation_for(widget, opts) do
    backend_mode = Keyword.get(opts, :backend_mode, :raw)

    explicit =
      Map.get(widget.metadata, :degradation_strategy) || Map.get(widget.metadata, :degradation)

    cond do
      not is_nil(explicit) and backend_mode == :tty ->
        explicit

      backend_mode == :tty and widget.kind in [:overlay, :popover, :dialog, :toast, :alert_dialog] ->
        :inline_overlay

      backend_mode == :tty and widget.kind in [:context_menu, :command_palette] ->
        :inline_menu_selection

      backend_mode == :tty and widget.kind in [:canvas, :canvas_surface, :absolute, :positioned] ->
        :ascii_canvas

      backend_mode == :tty and widget.kind in [:viewport, :scroll_region] ->
        :paged_scroll

      true ->
        nil
    end
  end

  defp layer_role_for(widget) do
    Map.get(widget.metadata, :overlay_role) ||
      if(widget.kind in Layer.kinds() or widget.kind in [:dialog, :toast, :alert_dialog],
        do: widget.kind
      )
  end

  defp normalize_id(nil), do: "anonymous"
  defp normalize_id(id), do: to_string(id)
end
