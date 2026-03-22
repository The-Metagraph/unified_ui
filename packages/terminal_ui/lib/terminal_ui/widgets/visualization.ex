defmodule TerminalUi.Widgets.Visualization do
  @moduledoc """
  Advanced visualization widgets for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [:gauge, :sparkline, :bar_chart, :line_chart, :timeline, :canvas]
  end

  @spec gauge(String.t() | atom(), keyword()) :: Widget.t()
  def gauge(id, opts \\ []) do
    Widget.new(:gauge,
      id: id,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :gauge), %{
          capability_profile: Keyword.get(opts, :capability_profile, :rich_terminal)
        }),
      state:
        Builder.state(opts, %{
          value: Keyword.get(opts, :value),
          severity: Keyword.get(opts, :severity)
        }),
      bindings: Builder.bindings(opts, %{value: Keyword.get(opts, :binding)}),
      attributes: %{
        value: Keyword.get(opts, :value),
        min: Keyword.get(opts, :min, 0),
        max: Keyword.get(opts, :max, 100),
        label: Keyword.get(opts, :label)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec sparkline(String.t() | atom(), [number()], keyword()) :: Widget.t()
  def sparkline(id, series, opts \\ []) do
    Widget.new(:sparkline,
      id: id,
      metadata: Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :sparkline)),
      attributes: %{series: [%{id: Keyword.get(opts, :series_id, :primary), values: series}]},
      styles: Builder.styles(opts)
    )
  end

  @spec bar_chart(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def bar_chart(id, series, opts \\ []) do
    chart(:bar_chart, id, series, opts)
  end

  @spec line_chart(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def line_chart(id, series, opts \\ []) do
    chart(:line_chart, id, series, opts)
  end

  @spec timeline(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def timeline(id, events, opts \\ []) do
    Widget.new(:timeline,
      id: id,
      metadata: Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :timeline)),
      attributes: %{
        events: Builder.normalize_items(events),
        mode: Keyword.get(opts, :mode, :relative)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec canvas(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def canvas(id, operations, opts \\ []) do
    Widget.new(:canvas,
      id: id,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :canvas), %{
          degradation_strategy: Keyword.get(opts, :degradation_strategy, :ascii_canvas)
        }),
      attributes: %{
        width: Keyword.get(opts, :width),
        height: Keyword.get(opts, :height),
        operations: Builder.normalize_items(operations)
      },
      events: Builder.events(select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  defp chart(kind, id, series, opts) do
    Widget.new(kind,
      id: id,
      metadata:
        Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, kind), %{
          capability_profile: Keyword.get(opts, :capability_profile, :rich_terminal)
        }),
      attributes: %{series: Builder.normalize_items(series), axes: Keyword.get(opts, :axes, %{})},
      styles: Builder.styles(opts)
    )
  end

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))
end
