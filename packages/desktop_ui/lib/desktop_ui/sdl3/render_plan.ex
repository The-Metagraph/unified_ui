defmodule DesktopUi.Sdl3.RenderPlan do
  @moduledoc """
  Retained render-plan structures for the SDL3 adapter seam.
  """

  alias DesktopUi.Runtime.{Error, State}
  alias DesktopUi.Sdl3.Window

  @enforce_keys [:runtime_id, :screen_id, :windows, :presentation, :diagnostics]
  defstruct [:runtime_id, :screen_id, :windows, :presentation, :diagnostics]

  @type t :: %__MODULE__{
          runtime_id: String.t(),
          screen_id: String.t(),
          windows: [map()],
          presentation: map(),
          diagnostics: map()
        }

  @spec build(State.t()) :: {:ok, t()} | {:error, Error.t()}
  def build(%State{} = runtime_state) do
    with {:ok, registry} <- Window.registry(runtime_state) do
      node_index = index_nodes(runtime_state.realization.tree)
      clip_regions = runtime_state.realization.viewport_regions

      windows =
        registry.sessions
        |> Enum.with_index()
        |> Enum.map(fn {session, index} ->
          draw_operations =
            session.owned_widget_ids
            |> Enum.filter(&Map.has_key?(node_index, &1))
            |> Enum.map(&draw_operation(Map.fetch!(node_index, &1), index))

          %{
            window_id: session.id,
            window_identity: session.window_identity,
            title: session.title,
            role: session.role,
            native_window?: session.native_window?,
            logical_bounds: logical_bounds(index),
            clip_regions:
              Enum.filter(clip_regions, &(&1.widget_id in session.owned_widget_ids)),
            transient_layers: session.transient_layers,
            draw_operations: draw_operations
          }
        end)

      {:ok,
       %__MODULE__{
         runtime_id: runtime_state.runtime_id,
         screen_id: runtime_state.screen_id,
         windows: windows,
         presentation: %{
           backend: :sdl_renderer,
           logical_units: true,
           placeholder_draw_operations: true,
           validation_state: :render_plan_ready
         },
         diagnostics: %{
           window_count: length(windows),
           draw_operation_count:
             windows |> Enum.flat_map(& &1.draw_operations) |> length(),
           clip_region_count:
             windows |> Enum.flat_map(& &1.clip_regions) |> length()
         }
       }}
    end
  end

  defp index_nodes(node) do
    node
    |> flatten_nodes([])
    |> Map.new(fn current -> {to_string(current.id), current} end)
  end

  defp flatten_nodes(node, acc) do
    Enum.reduce(Map.get(node, :children, []), acc ++ [node], &flatten_nodes(&1, &2))
  end

  defp logical_bounds(index) do
    %{
      x: 40 * index,
      y: 24 * index,
      width: 1280,
      height: 800,
      units: :logical
    }
  end

  defp draw_operation(node, window_index) do
    %{
      widget_id: node.id,
      kind: node.kind,
      family: node.family,
      draw_kind: placeholder_draw_kind(node),
      logical_bounds: draw_bounds(node, window_index),
      clip?: node.viewport || node.positioned,
      layer_role: node.layer_role,
      resolved_styles: Map.get(node, :resolved_styles, %{}),
      content:
        node.attributes[:content] || node.attributes[:label] ||
          node.attributes[:window_title] || to_string(node.kind)
    }
  end

  defp draw_bounds(node, window_index) do
    %{
      x: 16 * length(node.path),
      y: 12 * length(node.path) + 24 * window_index,
      width: 240,
      height: draw_height(node.kind),
      units: :logical
    }
  end

  defp draw_height(kind) when kind in [:text, :label], do: 24
  defp draw_height(kind) when kind in [:button, :checkbox, :toggle, :text_input], do: 36
  defp draw_height(kind) when kind in [:window, :dialog, :viewport, :split_pane], do: 220
  defp draw_height(_kind), do: 48

  defp placeholder_draw_kind(node) do
    cond do
      node.kind in [:window, :dialog] -> :window_chrome
      node.kind in [:overlay, :popover, :context_menu] -> :layer_surface
      node.viewport -> :viewport_region
      true -> :widget_placeholder
    end
  end
end
