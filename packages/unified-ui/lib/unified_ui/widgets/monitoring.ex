defmodule UnifiedUi.Widgets.LogViewer do
  @moduledoc """
  Monitoring widget for displaying log lines from a source.
  """

  defstruct [
    :id,
    :source,
    :filter,
    :style,
    lines: 100,
    auto_scroll: true,
    refresh_interval: 1_000,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          source: term(),
          lines: non_neg_integer(),
          auto_scroll: boolean(),
          filter: String.t() | nil,
          refresh_interval: non_neg_integer(),
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.LogViewer do
  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :log_viewer,
      id: widget.id,
      source: widget.source,
      lines: widget.lines,
      auto_scroll: widget.auto_scroll,
      filter: widget.filter,
      refresh_interval: widget.refresh_interval,
      auto_refresh: widget.refresh_interval > 0,
      style: widget.style,
      visible: widget.visible
    }
  end
end

defmodule UnifiedUi.Widgets.StreamWidget do
  @moduledoc """
  Monitoring widget for rendering data produced by a stream/producer.
  """

  @type transform_fun :: (term() -> term())

  defstruct [
    :id,
    :producer,
    :transform,
    :on_item,
    :style,
    buffer_size: 100,
    refresh_interval: 1_000,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          producer: term(),
          transform: transform_fun() | nil,
          buffer_size: pos_integer(),
          refresh_interval: non_neg_integer(),
          on_item: atom() | {atom(), map()} | nil,
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.StreamWidget do
  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :stream_widget,
      id: widget.id,
      producer: widget.producer,
      transform: widget.transform,
      buffer_size: widget.buffer_size,
      refresh_interval: widget.refresh_interval,
      auto_refresh: widget.refresh_interval > 0,
      on_item: widget.on_item,
      style: widget.style,
      visible: widget.visible
    }
  end
end

defmodule UnifiedUi.Widgets.ProcessMonitor do
  @moduledoc """
  Monitoring widget for process statistics and selection.
  """

  defstruct [
    :id,
    :node,
    :sort_by,
    :on_process_select,
    :style,
    refresh_interval: 1_000,
    visible: true
  ]

  @type t :: %__MODULE__{
          id: atom() | nil,
          node: atom() | nil,
          refresh_interval: non_neg_integer(),
          sort_by: atom() | nil,
          on_process_select: atom() | {atom(), map()} | nil,
          style: UnifiedIUR.Style.t() | nil,
          visible: boolean()
        }
end

defimpl UnifiedIUR.Element, for: UnifiedUi.Widgets.ProcessMonitor do
  def children(_widget), do: []

  def metadata(widget) do
    %{
      type: :process_monitor,
      id: widget.id,
      node: widget.node,
      refresh_interval: widget.refresh_interval,
      auto_refresh: widget.refresh_interval > 0,
      sort_by: widget.sort_by,
      on_process_select: widget.on_process_select,
      style: widget.style,
      visible: widget.visible
    }
  end
end
