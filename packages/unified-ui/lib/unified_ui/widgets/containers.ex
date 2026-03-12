defmodule UnifiedUi.Widgets.Viewport do
  @moduledoc """
  Scrollable container widget with optional clipping metadata.
  """

  @type content :: UnifiedIUR.Element.t() | nil
  @type border :: :none | :solid | :dashed | :double | boolean() | nil

  defstruct [
    :id,
    :content,
    :width,
    :height,
    :on_scroll,
    :border,
    :style,
    scroll_x: 0,
    scroll_y: 0,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          content: content(),
          width: integer() | nil,
          height: integer() | nil,
          scroll_x: integer(),
          scroll_y: integer(),
          on_scroll: atom() | {atom(), map()} | nil,
          border: border(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.Viewport do
  def children(%UnifiedUi.Widgets.Viewport{content: nil}), do: []
  def children(%UnifiedUi.Widgets.Viewport{content: content}), do: [content]

  def metadata(widget) do
    %{
      type: :viewport,
      id: widget.id,
      width: widget.width,
      height: widget.height,
      scroll_x: widget.scroll_x,
      scroll_y: widget.scroll_y,
      on_scroll: widget.on_scroll,
      border: widget.border,
      style: widget.style,
      visible: widget.visible
    }
  end
end

defmodule UnifiedUi.Widgets.SplitPane do
  @moduledoc """
  Two-pane resizable container widget.
  """

  @type pane :: UnifiedIUR.Element.t()
  @type orientation :: :horizontal | :vertical

  defstruct [
    :id,
    :on_resize_change,
    :style,
    panes: [],
    orientation: :horizontal,
    initial_split: 50,
    min_size: 10,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          panes: [pane()],
          orientation: orientation(),
          initial_split: integer(),
          min_size: integer(),
          on_resize_change: atom() | {atom(), map()} | nil,
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.SplitPane do
  def children(%UnifiedUi.Widgets.SplitPane{panes: panes}) when is_list(panes), do: panes
  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :split_pane,
      id: widget.id,
      orientation: widget.orientation,
      initial_split: widget.initial_split,
      min_size: widget.min_size,
      on_resize_change: widget.on_resize_change,
      style: widget.style,
      visible: widget.visible
    }
  end
end
