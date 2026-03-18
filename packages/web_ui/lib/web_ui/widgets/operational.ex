defmodule WebUi.Widgets.Operational do
  @moduledoc """
  Advanced operational and diagnostic widgets for direct-use `web_ui`
  workspaces.
  """

  alias WebUi.Widgets.Builder

  @kinds [
    :stream_widget,
    :process_monitor,
    :cluster_dashboard,
    :command_palette,
    :supervision_tree_viewer
  ]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec stream_widget([keyword() | map()], keyword() | map()) :: WebUi.Widget.t()
  def stream_widget(entries, opts \\ []) when is_list(entries) do
    opts = Builder.options(opts)

    Builder.widget(:stream_widget,
      id: Builder.require_id!(opts, :stream_widget),
      props: %{
        entries: normalize_entries(entries),
        ordering: Builder.option(opts, :ordering, :append_only),
        severity_field: Builder.option(opts, :severity_field),
        timestamp_field: Builder.option(opts, :timestamp_field)
      },
      state: Builder.state(opts, [:disabled?, :streaming?, :paused?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, change: :change),
      metadata: Builder.metadata(opts, %{native_surface: :operational, diagnostic_surface?: true})
    )
  end

  @spec process_monitor([keyword() | map()], keyword() | map()) :: WebUi.Widget.t()
  def process_monitor(processes, opts \\ []) when is_list(processes) do
    opts = Builder.options(opts)

    Builder.widget(:process_monitor,
      id: Builder.require_id!(opts, :process_monitor),
      props: %{
        processes: normalize_entities(processes),
        sort_by: Builder.option(opts, :sort_by),
        severity: Builder.option(opts, :severity)
      },
      state: Builder.state(opts, [:disabled?, :loading?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, sort: :sort, filter: :filter),
      metadata: Builder.metadata(opts, %{native_surface: :operational, diagnostic_surface?: true})
    )
  end

  @spec cluster_dashboard([keyword() | map()], keyword() | map()) :: WebUi.Widget.t()
  def cluster_dashboard(nodes, opts \\ []) when is_list(nodes) do
    opts = Builder.options(opts)

    Builder.widget(:cluster_dashboard,
      id: Builder.require_id!(opts, :cluster_dashboard),
      props: %{
        nodes: normalize_entities(nodes),
        summary: Builder.option(opts, :summary, %{}),
        severity: Builder.option(opts, :severity)
      },
      state: Builder.state(opts, [:disabled?, :loading?]),
      style_hooks: Builder.style_hooks(opts),
      metadata: Builder.metadata(opts, %{native_surface: :operational, diagnostic_surface?: true})
    )
  end

  @spec command_palette([keyword() | map()], keyword() | map()) :: WebUi.Widget.t()
  def command_palette(commands, opts \\ []) when is_list(commands) do
    opts = Builder.options(opts)

    Builder.widget(:command_palette,
      id: Builder.require_id!(opts, :command_palette),
      props: %{
        commands: normalize_entities(commands),
        query: Builder.option(opts, :query),
        active_command: Builder.option(opts, :active_command),
        placeholder: Builder.option(opts, :placeholder)
      },
      state: Builder.state(opts, [:disabled?, :focused?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, change: :change, command: :command),
      metadata: Builder.metadata(opts, %{native_surface: :operational, diagnostic_surface?: true})
    )
  end

  @spec supervision_tree_viewer([keyword() | map()], keyword() | map()) :: WebUi.Widget.t()
  def supervision_tree_viewer(nodes, opts \\ []) when is_list(nodes) do
    opts = Builder.options(opts)

    Builder.widget(:supervision_tree_viewer,
      id: Builder.require_id!(opts, :supervision_tree_viewer),
      props: %{
        nodes: normalize_hierarchy(nodes),
        expanded?: Builder.option(opts, :expanded?, true),
        show_restarts?: Builder.option(opts, :show_restarts?, true)
      },
      state: Builder.state(opts, [:disabled?, :loading?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, expand: :expand),
      metadata: Builder.metadata(opts, %{native_surface: :operational, diagnostic_surface?: true})
    )
  end

  defp normalize_entries(entries) do
    Enum.map(entries, fn entry ->
      entry = Builder.options(entry)

      %{}
      |> Builder.maybe_put(:id, Builder.option(entry, :id))
      |> Builder.maybe_put(:message, Builder.option(entry, :message))
      |> Builder.maybe_put(:severity, Builder.option(entry, :severity))
      |> Builder.maybe_put(:timestamp, Builder.option(entry, :timestamp))
      |> Builder.maybe_put(:metadata, Builder.option(entry, :metadata))
    end)
  end

  defp normalize_entities(items) do
    Enum.map(items, fn item ->
      item
      |> Builder.options()
      |> Map.new()
    end)
  end

  defp normalize_hierarchy(nodes) do
    Enum.map(nodes, fn node ->
      node = Builder.options(node)
      children = node |> Builder.option(:children, []) |> normalize_hierarchy()

      %{}
      |> Builder.maybe_put(:id, Builder.option(node, :id))
      |> Builder.maybe_put(:label, Builder.option(node, :label))
      |> Builder.maybe_put(:type, Builder.option(node, :type))
      |> Builder.maybe_put(:status, Builder.option(node, :status))
      |> Builder.maybe_put(:restarts, Builder.option(node, :restarts))
      |> Builder.maybe_put(:children, if(children == [], do: nil, else: children))
    end)
  end
end
