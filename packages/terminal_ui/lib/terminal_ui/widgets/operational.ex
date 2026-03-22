defmodule TerminalUi.Widgets.Operational do
  @moduledoc """
  Advanced operational and diagnostic widgets for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [:log_viewer, :stream_widget, :cluster_dashboard, :command_palette, :process_monitor]
  end

  @spec log_viewer(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def log_viewer(id, entries, opts \\ []) do
    Widget.new(:log_viewer,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :log_viewer], opts),
          %{
            degradation_strategy: Keyword.get(opts, :degradation_strategy, :plain_log)
          }
        ),
      state:
        Builder.state(opts, %{
          streaming: Keyword.get(opts, :streaming, false),
          paused: Keyword.get(opts, :paused, false)
        }),
      bindings:
        Builder.bindings(opts, %{
          filters: Keyword.get(opts, :filters_binding),
          query: Keyword.get(opts, :query_binding)
        }),
      attributes: %{
        entries: Builder.normalize_items(entries),
        follow: Keyword.get(opts, :follow, false),
        query: Keyword.get(opts, :query)
      },
      events: Builder.events(filter: opts[:on_filter], paginate: opts[:on_paginate]),
      styles: Builder.styles(opts)
    )
  end

  @spec stream_widget(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def stream_widget(id, entries, opts \\ []) do
    Widget.new(:stream_widget,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :stream_widget], opts)
        ),
      state:
        Builder.state(opts, %{
          streaming: Keyword.get(opts, :streaming, true),
          paused: Keyword.get(opts, :paused, false)
        }),
      attributes: %{
        entries: Builder.normalize_items(entries),
        ordering: Keyword.get(opts, :ordering, :append_only)
      },
      events: Builder.events(change: opts[:on_change]),
      styles: Builder.styles(opts)
    )
  end

  @spec cluster_dashboard(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def cluster_dashboard(id, nodes, opts \\ []) do
    Widget.new(:cluster_dashboard,
      id: id,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :cluster_dashboard)),
      state:
        Builder.state(opts, %{
          loading: Keyword.get(opts, :loading, false),
          severity: Keyword.get(opts, :severity)
        }),
      attributes: %{
        nodes: Builder.normalize_items(nodes),
        summary: Keyword.get(opts, :summary, %{})
      },
      styles: Builder.styles(opts)
    )
  end

  @spec command_palette(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def command_palette(id, commands, opts \\ []) do
    Widget.new(:command_palette,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :command_palette], opts),
          %{
            degradation_strategy: Keyword.get(opts, :degradation_strategy, :inline_menu)
          }
        ),
      state:
        Builder.state(opts, %{
          open: Keyword.get(opts, :open, false),
          current: Keyword.get(opts, :current)
        }),
      bindings:
        Builder.bindings(opts, %{
          query: Keyword.get(opts, :query_binding, Keyword.get(opts, :binding))
        }),
      attributes: %{commands: Builder.normalize_items(commands), query: Keyword.get(opts, :query)},
      events:
        Builder.events(
          change: opts[:on_change],
          command: opts[:on_command],
          select: opts[:on_select]
        ),
      styles: Builder.styles(opts)
    )
  end

  @spec process_monitor(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def process_monitor(id, processes, opts \\ []) do
    Widget.new(:process_monitor,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :process_monitor], opts)
        ),
      state:
        Builder.state(opts, %{
          loading: Keyword.get(opts, :loading, false),
          selected: Keyword.get(opts, :selected)
        }),
      bindings:
        Builder.bindings(opts, %{
          selection: Keyword.get(opts, :selection_binding, Keyword.get(opts, :binding))
        }),
      attributes: %{
        processes: Builder.normalize_items(processes),
        sort_by: Keyword.get(opts, :sort_by)
      },
      events:
        Builder.events(sort: opts[:on_sort], filter: opts[:on_filter], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
