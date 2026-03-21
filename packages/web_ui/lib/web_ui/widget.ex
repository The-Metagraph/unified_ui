defmodule WebUi.Widget do
  @moduledoc """
  Native renderer-facing widget representation for `web_ui`.
  """

  @type family ::
          :content
          | :layout
          | :interaction
          | :feedback
          | :input
          | :navigation
          | :data
          | :document
          | :visualization
          | :operational

  @type t :: %__MODULE__{
          id: String.t() | atom() | nil,
          family: family(),
          kind: atom(),
          metadata: map(),
          state: map(),
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
            slots: [:default],
            slot_children: %{},
            attributes: %{},
            styles: %{},
            events: %{},
            children: []

  @spec contract() :: map()
  def contract do
    %{
      metadata: [:label, :description, :role, :variant, :native_surface],
      state: [
        :disabled,
        :selected,
        :expanded,
        :focused,
        :editing,
        :current,
        :checked,
        :loading,
        :streaming,
        :paused
      ],
      slots: [:default, :label, :control, :help, :header, :body, :navigation],
      styles: [:tone, :size, :spacing, :surface, :hooks],
      events: [
        :click,
        :change,
        :submit,
        :navigation,
        :focus,
        :sort,
        :filter,
        :paginate,
        :close,
        :expand,
        :command
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

  @spec put_state(t(), atom() | String.t(), term()) :: t()
  def put_state(%__MODULE__{} = widget, key, value) do
    %{widget | state: Map.put(widget.state, key, value)}
  end

  @spec put_event(t(), atom() | String.t(), map()) :: t()
  def put_event(%__MODULE__{} = widget, key, value) when is_map(value) do
    %{widget | events: Map.put(widget.events, key, value)}
  end

  @spec put_slot(t(), atom() | String.t()) :: t()
  def put_slot(%__MODULE__{} = widget, slot) when is_atom(slot) or is_binary(slot) do
    %{widget | slots: Enum.uniq(widget.slots ++ [slot])}
  end

  @spec serialize(t()) :: map()
  def serialize(%__MODULE__{} = widget) do
    %{
      id: widget.id,
      family: widget.family,
      kind: widget.kind,
      metadata: widget.metadata,
      state: widget.state,
      slots: widget.slots,
      slot_children:
        Map.new(widget.slot_children, fn {slot, children} ->
          {slot, Enum.map(children, &serialize/1)}
        end),
      attributes: widget.attributes,
      styles: widget.styles,
      events: widget.events,
      children: Enum.map(widget.children, &serialize/1)
    }
  end

  @spec family_for(atom()) :: family()
  def family_for(kind) when kind in [:stack, :panel, :container, :row, :column], do: :layout
  def family_for(kind) when kind in [:button, :link, :form], do: :interaction

  def family_for(kind) when kind in [:text_input, :checkbox, :select, :field, :field_group],
    do: :input

  def family_for(kind) when kind in [:tabs, :menu], do: :navigation
  def family_for(kind) when kind in [:table, :tree_view], do: :data
  def family_for(kind) when kind in [:markdown_viewer, :log_viewer], do: :document
  def family_for(kind) when kind in [:status, :progress, :inline_feedback], do: :feedback

  def family_for(kind)
      when kind in [:gauge, :sparkline, :bar_chart, :line_chart, :canvas],
      do: :visualization

  def family_for(kind)
      when kind in [
             :stream_widget,
             :process_monitor,
             :cluster_dashboard,
             :command_palette,
             :supervision_tree_viewer
           ],
      do: :operational

  def family_for(_kind), do: :content

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp normalize_slots(slots) when is_list(slots), do: slots
  defp normalize_slots(_slots), do: [:default]

  defp normalize_slot_children(nil, children) do
    case normalize_children(children) do
      [] -> %{}
      normalized -> %{default: normalized}
    end
  end

  defp normalize_slot_children(slot_children, _children) when is_map(slot_children) do
    Map.new(slot_children, fn {slot, children} ->
      {slot, normalize_children(children)}
    end)
  end

  defp normalize_children(children) when is_list(children) do
    Enum.map(children, fn
      %__MODULE__{} = child ->
        child

      child when is_map(child) ->
        new(Map.get(child, :kind) || Map.get(child, "kind") || :text, child)
    end)
  end

  defp normalize_children(%__MODULE__{} = child), do: [child]
  defp normalize_children(nil), do: []

  defp flatten_slot_children(slot_children) do
    slot_children
    |> Enum.flat_map(fn {_slot, children} -> children end)
  end
end
