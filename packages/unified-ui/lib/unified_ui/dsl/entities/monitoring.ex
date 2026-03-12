defmodule UnifiedUi.Dsl.Entities.Monitoring do
  @moduledoc """
  Spark DSL entity definitions for monitoring widgets.

  This module defines:
  - log_viewer
  - stream_widget
  - process_monitor
  """

  alias UnifiedUi.Widgets.{LogViewer, ProcessMonitor, StreamWidget}

  @signal_type {:or, [:atom, {:tuple, [:atom, :map]}, {:tuple, [:atom, :atom, {:list, :any}]}]}

  @log_viewer_entity %Spark.Dsl.Entity{
    name: :log_viewer,
    target: LogViewer,
    args: [:id],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the log viewer.",
        required: true
      ],
      source: [
        type: :any,
        doc: "Log source (path, process, or stream reference).",
        required: false
      ],
      lines: [
        type: :integer,
        doc: "Number of lines to retain/render.",
        required: false,
        default: 100
      ],
      auto_scroll: [
        type: :boolean,
        doc: "Whether new lines auto-scroll to the end.",
        required: false,
        default: true
      ],
      filter: [
        type: :string,
        doc: "Optional text filter applied to displayed lines.",
        required: false
      ],
      refresh_interval: [
        type: :integer,
        doc: "Auto-refresh interval in milliseconds.",
        required: false,
        default: 1_000
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the log viewer is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A widget for tailing and filtering logs from a source.
    """
  }

  @stream_widget_entity %Spark.Dsl.Entity{
    name: :stream_widget,
    target: StreamWidget,
    args: [:id, :producer],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the stream widget.",
        required: true
      ],
      producer: [
        type: :any,
        doc: "Stream or producer reference.",
        required: true
      ],
      transform: [
        type: {:fun, 1},
        doc: "Optional transform function applied to incoming items.",
        required: false
      ],
      buffer_size: [
        type: :integer,
        doc: "Maximum item buffer retained for rendering.",
        required: false,
        default: 100
      ],
      refresh_interval: [
        type: :integer,
        doc: "Auto-refresh interval in milliseconds.",
        required: false,
        default: 1_000
      ],
      on_item: [
        type: @signal_type,
        doc: "Signal emitted when stream items are processed.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the stream widget is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A widget that renders and updates from producer-driven stream data.
    """
  }

  @process_monitor_entity %Spark.Dsl.Entity{
    name: :process_monitor,
    target: ProcessMonitor,
    args: [:id],
    schema: [
      id: [
        type: :atom,
        doc: "Unique identifier for the process monitor.",
        required: true
      ],
      node: [
        type: :atom,
        doc: "Node to inspect. Defaults to the local node when omitted.",
        required: false
      ],
      refresh_interval: [
        type: :integer,
        doc: "Polling interval in milliseconds.",
        required: false,
        default: 1_000
      ],
      sort_by: [
        type: :atom,
        doc: "Sort key for process list (for example :memory, :reductions, :pid).",
        required: false,
        default: :memory
      ],
      on_process_select: [
        type: @signal_type,
        doc: "Signal emitted when a process row is selected.",
        required: false
      ],
      style: [
        type: :keyword_list,
        doc: "Inline style as keyword list.",
        required: false
      ],
      visible: [
        type: :boolean,
        doc: "Whether the process monitor is visible.",
        required: false,
        default: true
      ]
    ],
    describe: """
    A widget for monitoring process statistics on a node.
    """
  }

  @doc false
  @spec log_viewer_entity() :: Spark.Dsl.Entity.t()
  def log_viewer_entity, do: @log_viewer_entity

  @doc false
  @spec stream_widget_entity() :: Spark.Dsl.Entity.t()
  def stream_widget_entity, do: @stream_widget_entity

  @doc false
  @spec process_monitor_entity() :: Spark.Dsl.Entity.t()
  def process_monitor_entity, do: @process_monitor_entity
end
