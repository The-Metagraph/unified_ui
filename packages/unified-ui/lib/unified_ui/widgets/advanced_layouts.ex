defmodule UnifiedUi.Widgets.Grid do
  @moduledoc """
  Advanced layout container that arranges children in grid tracks.
  """

  @type track_size :: pos_integer() | String.t() | :auto

  defstruct [
    :id,
    :columns,
    :rows,
    :style,
    children: [],
    gap: 0,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          children: [UnifiedIUR.Element.t()],
          columns: [track_size()],
          rows: [track_size()],
          gap: non_neg_integer(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.Grid do
  def children(%UnifiedUi.Widgets.Grid{children: children}) when is_list(children), do: children
  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :grid,
      id: widget.id,
      columns: widget.columns,
      rows: widget.rows,
      gap: widget.gap,
      style: widget.style,
      visible: widget.visible
    }
  end
end

defmodule UnifiedUi.Widgets.Stack do
  @moduledoc """
  Advanced layout container that renders a single active child by index.
  """

  @type transition :: atom() | String.t() | nil

  defstruct [
    :id,
    :transition,
    :style,
    children: [],
    active_index: 0,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          children: [UnifiedIUR.Element.t()],
          active_index: non_neg_integer(),
          transition: transition(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.Stack do
  def children(%UnifiedUi.Widgets.Stack{children: children}) when is_list(children), do: children
  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :stack,
      id: widget.id,
      active_index: widget.active_index,
      transition: widget.transition,
      style: widget.style,
      visible: widget.visible
    }
  end
end

defmodule UnifiedUi.Widgets.ZBox do
  @moduledoc """
  Advanced layout container with absolute child positioning metadata.
  """

  @type position ::
          %{
            optional(:x) => integer(),
            optional(:y) => integer(),
            optional(:z) => integer(),
            optional(:z_index) => integer(),
            optional(:width) => integer(),
            optional(:height) => integer()
          }

  @type positions :: %{optional(integer() | atom()) => position()} | nil

  defstruct [
    :id,
    :positions,
    :style,
    children: [],
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          children: [UnifiedIUR.Element.t()],
          positions: positions(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.ZBox do
  def children(%UnifiedUi.Widgets.ZBox{children: children}) when is_list(children), do: children
  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :zbox,
      id: widget.id,
      positions: widget.positions || %{},
      style: widget.style,
      visible: widget.visible
    }
  end
end
