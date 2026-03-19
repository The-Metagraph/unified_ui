defmodule WebUi.ServerRuntime.ViewState do
  @moduledoc """
  Server-side view state generation for web_ui widgets.

  This module handles the deterministic generation of view state for
  foundational widgets. It ensures that widget identity, slots, styles,
  and interaction wiring are consistently represented for frontend rendering.
  """

  alias WebUi.Widgets.Native.Widget

  @type widget_id :: String.t()
  @type widget_ref :: {module(), atom()}
  @type slot_name :: atom()
  @type style_key :: atom()
  @type style_value :: String.t() | atom() | integer()

  @type widget_state :: %{
    id: widget_id(),
    type: String.t(),
    widget_module: module(),
    props: map(),
    state: map(),
    slots: %{optional(slot_name()) => list(widget_state())},
    styles: %{optional(style_key()) => style_value()},
    events: %{optional(String.t()) => atom()}
  }

  @type t :: %{
    root: widget_state(),
    widgets: %{optional(widget_id()) => widget_state()},
    version: String.t(),
    checksum: String.t()
  }

  @doc """
  Generates view state from a widget tree.

  Takes a root widget and recursively generates deterministic view state
  for all widgets in the tree.
  """
  @spec from_widget(module(), map(), keyword()) :: {:ok, t()} | {:error, term()}
  def from_widget(widget_module, props, opts \\ []) do
    with {:ok, root_widget} <- Widget.create(widget_module, props, opts) do
      widget_states = do_build_widget_tree(root_widget, [], widget_module)
        |> Enum.reverse()

      view_state = %{
        root: hd(widget_states),
        widgets: index_widgets(widget_states),
        version: "1.0.0",
        checksum: checksum_for(widget_states)
      }

      {:ok, view_state}
    end
  end

  @doc """
  Converts view state to frontend-compatible map.

  This produces the data structure sent to the Elm frontend for hydration.
  """
  @spec to_frontend_map(t()) :: map()
  def to_frontend_map(%{root: root, widgets: widgets, version: version}) do
    %{
      root: widget_to_frontend(root),
      widgets: Enum.map(widgets, fn {id, w} -> {id, widget_to_frontend(w)} end) |> Map.new(),
      version: version
    }
  end

  @doc """
  Retrieves a specific widget by its ID.
  """
  @spec get_widget(t(), widget_id()) :: {:ok, widget_state()} | :error
  def get_widget(%{widgets: widgets}, id) do
    Map.fetch(widgets, id)
  end

  @doc """
  Updates widget props in the view state.
  """
  @spec update_widget_props(t(), widget_id(), map()) :: {:ok, t()} | :error
  def update_widget_props(%{widgets: widgets} = view_state, id, new_props) do
    with {:ok, widget} <- Map.fetch(widgets, id) do
      updated_widget = %{widget | props: Map.merge(widget.props, new_props)}
      updated_widgets = Map.put(widgets, id, updated_widget)

      updated_state = %{
        view_state
        | widgets: updated_widgets,
          checksum: checksum_for(Map.values(updated_widgets))
      }

      {:ok, updated_state}
    end
  end

  # Private functions

  defp do_build_widget_tree(widget, acc, widget_module) do
    widget_id = generate_widget_id(widget, widget_module)
    widget_state = widget_to_state(widget, widget_id, widget_module)

    # Process child widgets in slots
    widget_state_with_children =
      Enum.reduce(widget.slots || %{}, widget_state, fn {slot_name, slot_widgets}, acc_state ->
        children_states =
          Enum.flat_map(slot_widgets || [], fn child_widget ->
            # For child widgets, use the same module for now
            # In a real implementation, each widget would track its own module
            do_build_widget_tree(child_widget, [], widget_module)
          end)

        %{acc_state | slots: Map.put(acc_state.slots, slot_name, children_states)}
      end)

    [widget_state_with_children | acc]
  end

  defp widget_to_state(widget, id, widget_module) do
    %{
      id: id,
      type: Atom.to_string(widget.id),
      widget_module: widget_module,
      props: widget.props,
      state: widget.state,
      slots: %{},
      styles: extract_styles(widget),
      events: Map.get(widget, :events, %{})
    }
  end

  defp generate_widget_id(widget, widget_module) do
    type = Atom.to_string(widget.id)
    # Generate deterministic ID based on module and props
    hash = :crypto.hash(:md5, :erlang.term_to_binary({widget_module, widget.props}))
    |> Base.encode16(case: :lower)
    |> String.slice(0, 8)
    "#{type}_#{hash}"
  end

  defp index_widgets(widgets) do
    Enum.reduce(widgets, %{}, fn w, acc ->
      # First add all children in slots
      acc_with_children =
        Enum.reduce(w.slots, acc, fn {_slot_name, slot_widgets}, inner_acc ->
          Enum.reduce(slot_widgets, inner_acc, fn child, child_acc ->
            Map.put(child_acc, child.id, child)
          end)
        end)

      # Then add this widget
      Map.put(acc_with_children, w.id, w)
    end)
  end

  defp extract_styles(widget) do
    # Extract styles from widget props or apply default styles based on widget type
    base_styles = base_styles_for(widget.id)
    custom_styles = Map.get(widget.props, :styles, %{})
    Map.merge(base_styles, custom_styles)
  end

  defp base_styles_for(:text), do: %{font_weight: :normal}
  defp base_styles_for(:label), do: %{font_weight: :medium}
  defp base_styles_for(:button), do: %{cursor: :pointer}
  defp base_styles_for(:link), do: %{cursor: :pointer, text_decoration: :underline}
  defp base_styles_for(:image), do: %{max_width: "100%"}
  defp base_styles_for(:spacer), do: %{display: :block}
  defp base_styles_for(:separator), do: %{width: "100%"}
  defp base_styles_for(:content), do: %{display: :flex, flex_direction: :column}
  defp base_styles_for(:icon), do: %{display: :inline_block}
  defp base_styles_for(_), do: %{}

  defp widget_to_frontend(widget) do
    %{
      id: widget.id,
      type: widget.type,
      props: widget.props,
      state: widget.state,
      slots: slots_to_frontend(widget.slots),
      styles: widget.styles,
      events: widget.events
    }
  end

  defp slots_to_frontend(slots) do
    Enum.map(slots, fn {slot_name, slot_widgets} ->
      {slot_name, Enum.map(slot_widgets, fn w -> w.id end)}
    end)
    |> Map.new()
  end

  defp checksum_for(widgets) do
    :crypto.hash(:md5, :erlang.term_to_binary(widgets))
    |> Base.encode16(case: :lower)
  end
end
