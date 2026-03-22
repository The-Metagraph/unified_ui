defmodule TerminalUi.Widget do
  @moduledoc """
  Native renderer-facing widget representation for `terminal_ui`.
  """

  @type family ::
          :content
          | :action
          | :layout
          | :input
          | :navigation
          | :data
          | :feedback
          | :visualization
          | :operational

  @type t :: %__MODULE__{
          id: String.t() | atom() | nil,
          family: family(),
          kind: atom(),
          metadata: map(),
          state: map(),
          bindings: map(),
          slots: [atom() | String.t()],
          slot_children: %{optional(atom() | String.t()) => [t()]},
          attributes: map(),
          styles: map(),
          events: map(),
          children: [t()]
        }

  defstruct id: nil,
            family: :content,
            kind: :text,
            metadata: %{},
            state: %{},
            bindings: %{},
            slots: [:default],
            slot_children: %{},
            attributes: %{},
            styles: %{},
            events: %{},
            children: []

  @spec contract() :: map()
  def contract do
    %{
      metadata: [
        :label,
        :description,
        :role,
        :variant,
        :native_surface,
        :degradation,
        :shortcut,
        :focusable,
        :binding_key,
        :command,
        :keyboard_hint,
        :selection_mode,
        :sort_key,
        :overlay_role,
        :capability_profile,
        :degradation_strategy
      ],
      state: [
        :disabled,
        :focused,
        :selected,
        :expanded,
        :open,
        :loading,
        :fallback,
        :checked,
        :active,
        :current,
        :value,
        :severity,
        :paused,
        :streaming,
        :progress,
        :phase
      ],
      bindings: [:value, :checked, :selected, :current, :items, :query, :filters, :selection],
      slots: [:default, :label, :content, :header, :footer, :overlay],
      styles: [
        :fg,
        :bg,
        :attrs,
        :border,
        :padding,
        :semantic_role,
        :degradation,
        :intent,
        :overlay_tone,
        :chart_palette
      ],
      events: [
        :keypress,
        :submit,
        :navigation,
        :focus,
        :dismiss,
        :scroll,
        :command,
        :select,
        :change,
        :toggle,
        :activate,
        :sort,
        :filter,
        :paginate,
        :expand,
        :close
      ]
    }
  end

  @spec new(atom(), keyword() | map()) :: t()
  def new(kind, attrs \\ %{}) when is_atom(kind) do
    attrs = normalize_map(attrs)
    raw_children = Map.get(attrs, :children) || Map.get(attrs, "children") || []
    slot_children = normalize_slot_children(Map.get(attrs, :slot_children), raw_children)
    slots = Map.get(attrs, :slots) || Map.get(attrs, "slots") || Map.keys(slot_children)

    %__MODULE__{
      id: Map.get(attrs, :id) || Map.get(attrs, "id"),
      family: Map.get(attrs, :family) || Map.get(attrs, "family") || family_for(kind),
      kind: kind,
      metadata: normalize_map(Map.get(attrs, :metadata) || Map.get(attrs, "metadata")),
      state: normalize_map(Map.get(attrs, :state) || Map.get(attrs, "state")),
      bindings: normalize_map(Map.get(attrs, :bindings) || Map.get(attrs, "bindings")),
      slots: normalize_slots(slots),
      slot_children: slot_children,
      attributes: normalize_map(Map.get(attrs, :attributes) || Map.get(attrs, "attributes")),
      styles: normalize_map(Map.get(attrs, :styles) || Map.get(attrs, "styles")),
      events: normalize_map(Map.get(attrs, :events) || Map.get(attrs, "events")),
      children: flatten_slot_children(slot_children)
    }
  end

  @spec put_child(t(), t()) :: t()
  def put_child(%__MODULE__{} = widget, %__MODULE__{} = child) do
    put_child(widget, :default, child)
  end

  @spec put_child(t(), atom() | String.t(), t()) :: t()
  def put_child(%__MODULE__{} = widget, slot, %__MODULE__{} = child) do
    next_slot_children =
      Map.update(widget.slot_children, slot, [child], fn children -> children ++ [child] end)

    %{
      widget
      | slot_children: next_slot_children,
        slots: normalize_slots(Map.keys(next_slot_children)),
        children: flatten_slot_children(next_slot_children)
    }
  end

  @spec put_style(t(), atom() | String.t(), term()) :: t()
  def put_style(%__MODULE__{} = widget, key, value) do
    %{widget | styles: Map.put(widget.styles, key, value)}
  end

  @spec put_binding(t(), atom() | String.t(), term()) :: t()
  def put_binding(%__MODULE__{} = widget, key, value) do
    %{widget | bindings: Map.put(widget.bindings, key, value)}
  end

  @spec put_event(t(), atom() | String.t(), map()) :: t()
  def put_event(%__MODULE__{} = widget, key, value) when is_map(value) do
    %{widget | events: Map.put(widget.events, key, value)}
  end

  @spec family_for(atom()) :: family()
  def family_for(kind) when kind in [:container, :column, :row, :stack], do: :layout
  def family_for(kind) when kind in [:button, :toggle, :link, :command], do: :action
  def family_for(kind) when kind in [:text_input, :checkbox, :radio_group, :select], do: :input
  def family_for(kind) when kind in [:menu, :tabs, :breadcrumbs, :list], do: :navigation
  def family_for(kind) when kind in [:table, :tree_view, :inspector, :markdown_viewer], do: :data

  def family_for(kind) when kind in [:dialog, :toast, :alert_dialog, :progress, :status],
    do: :feedback

  def family_for(kind)
      when kind in [:gauge, :sparkline, :bar_chart, :line_chart, :timeline, :canvas],
      do: :visualization

  def family_for(kind)
      when kind in [
             :log_viewer,
             :stream_widget,
             :cluster_dashboard,
             :command_palette,
             :process_monitor,
             :supervision_tree_viewer
           ],
      do: :operational

  def family_for(_kind), do: :content

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Map.new(list)

  defp normalize_slot_children(nil, raw_children) do
    %{default: Enum.map(List.wrap(raw_children), &normalize_child/1)}
  end

  defp normalize_slot_children(slot_children, _raw_children) when is_map(slot_children) do
    Map.new(slot_children, fn {slot, children} ->
      {slot, Enum.map(List.wrap(children), &normalize_child/1)}
    end)
  end

  defp normalize_slots(slots) do
    slots
    |> List.wrap()
    |> Enum.map(fn slot -> slot end)
    |> Enum.uniq()
  end

  defp normalize_child(%__MODULE__{} = child), do: child
  defp normalize_child(attrs) when is_map(attrs), do: new(Map.get(attrs, :kind, :text), attrs)

  defp flatten_slot_children(slot_children) do
    slot_children
    |> Map.values()
    |> List.flatten()
  end
end
