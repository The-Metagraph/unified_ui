defmodule TerminalUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for native `terminal_ui` widgets.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.{Builder, Data, Feedback, Foundational, Input, Navigation}
  alias TerminalUi.Widgets.{Operational, Visualization}

  @type family :: Widget.family()

  @spec families() :: [family()]
  def families do
    kinds()
    |> Enum.map(&family_for_kind/1)
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec modules() :: [module()]
  def modules do
    [
      __MODULE__,
      Widget,
      Foundational,
      Input,
      Navigation,
      Data,
      Feedback,
      Visualization,
      Operational
    ]
  end

  @spec kinds() :: [atom()]
  def kinds do
    [
      Foundational.kinds(),
      Input.kinds(),
      Navigation.kinds(),
      Data.kinds(),
      Feedback.kinds(),
      Visualization.kinds(),
      Operational.kinds(),
      [:container, :column, :row, :stack, :dialog]
    ]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec family_for_kind(atom() | String.t()) :: family()
  def family_for_kind(kind) when is_binary(kind),
    do: kind |> String.to_atom() |> family_for_kind()

  def family_for_kind(kind), do: Widget.family_for(kind)

  @spec validation_state() :: map()
  def validation_state do
    %{
      widget_contract: :ready,
      registration_surface: :ready,
      direct_native_scaffold: :ready,
      foundational_content_widgets: :ready,
      foundational_action_widgets: :ready,
      foundational_form_widgets: :ready,
      foundational_navigation_widgets: :ready,
      focus_and_shortcut_metadata: :ready,
      advanced_data_widgets: :ready,
      advanced_feedback_widgets: :ready,
      advanced_visualization_widgets: :ready,
      advanced_operational_widgets: :ready,
      advanced_degradation_metadata: :ready
    }
  end

  @spec text(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def text(id, content, opts \\ []) do
    Foundational.text(id, content, opts)
  end

  @spec label(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def label(id, content, opts \\ []) do
    Foundational.label(id, content, opts)
  end

  @spec icon(String.t() | atom(), atom() | String.t(), keyword()) :: Widget.t()
  def icon(id, name, opts \\ []) do
    Foundational.icon(id, name, opts)
  end

  @spec image(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def image(id, src, opts \\ []) do
    Foundational.image(id, src, opts)
  end

  @spec spacer(String.t() | atom(), keyword()) :: Widget.t()
  def spacer(id, opts \\ []) do
    Foundational.spacer(id, opts)
  end

  @spec separator(String.t() | atom(), keyword()) :: Widget.t()
  def separator(id, opts \\ []) do
    Foundational.separator(id, opts)
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def button(id, label, opts \\ []) do
    Foundational.button(id, label, opts)
  end

  @spec toggle(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def toggle(id, label, opts \\ []) do
    Foundational.toggle(id, label, opts)
  end

  @spec link(String.t() | atom(), String.t(), String.t(), keyword()) :: Widget.t()
  def link(id, label, target, opts \\ []) do
    Foundational.link(id, label, target, opts)
  end

  @spec command(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def command(id, label, opts \\ []) do
    Foundational.command(id, label, opts)
  end

  @spec text_input(String.t() | atom(), keyword()) :: Widget.t()
  def text_input(id, opts \\ []) do
    Input.text_input(id, opts)
  end

  @spec checkbox(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def checkbox(id, label, opts \\ []) do
    Input.checkbox(id, label, opts)
  end

  @spec radio_group(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def radio_group(id, options, opts \\ []) do
    Input.radio_group(id, options, opts)
  end

  @spec select(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def select(id, options, opts \\ []) do
    Input.select(id, options, opts)
  end

  @spec tabs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def tabs(id, items, opts \\ []) do
    Navigation.tabs(id, items, opts)
  end

  @spec menu(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    Navigation.menu(id, items, opts)
  end

  @spec breadcrumbs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def breadcrumbs(id, items, opts \\ []) do
    Navigation.breadcrumbs(id, items, opts)
  end

  @spec list(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def list(id, items, opts \\ []) do
    Navigation.list(id, items, opts)
  end

  @spec table(String.t() | atom(), [keyword() | map()], [keyword() | map()], keyword()) ::
          Widget.t()
  def table(id, columns, rows, opts \\ []) do
    Data.table(id, columns, rows, opts)
  end

  @spec tree_view(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def tree_view(id, nodes, opts \\ []) do
    Data.tree_view(id, nodes, opts)
  end

  @spec inspector(String.t() | atom(), map() | keyword(), keyword()) :: Widget.t()
  def inspector(id, subject, opts \\ []) do
    Data.inspector(id, subject, opts)
  end

  @spec markdown_viewer(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def markdown_viewer(id, markdown, opts \\ []) do
    Data.markdown_viewer(id, markdown, opts)
  end

  @spec toast(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def toast(id, message, opts \\ []) do
    Feedback.toast(id, message, opts)
  end

  @spec alert_dialog(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def alert_dialog(id, message, children, opts \\ []) do
    Feedback.alert_dialog(id, message, children, opts)
  end

  @spec progress(String.t() | atom(), keyword()) :: Widget.t()
  def progress(id, opts \\ []) do
    Feedback.progress(id, opts)
  end

  @spec status(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def status(id, text, opts \\ []) do
    Feedback.status(id, text, opts)
  end

  @spec gauge(String.t() | atom(), keyword()) :: Widget.t()
  def gauge(id, opts \\ []) do
    Visualization.gauge(id, opts)
  end

  @spec sparkline(String.t() | atom(), [number()], keyword()) :: Widget.t()
  def sparkline(id, series, opts \\ []) do
    Visualization.sparkline(id, series, opts)
  end

  @spec bar_chart(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def bar_chart(id, series, opts \\ []) do
    Visualization.bar_chart(id, series, opts)
  end

  @spec line_chart(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def line_chart(id, series, opts \\ []) do
    Visualization.line_chart(id, series, opts)
  end

  @spec timeline(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def timeline(id, events, opts \\ []) do
    Visualization.timeline(id, events, opts)
  end

  @spec canvas(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def canvas(id, operations, opts \\ []) do
    Visualization.canvas(id, operations, opts)
  end

  @spec log_viewer(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def log_viewer(id, entries, opts \\ []) do
    Operational.log_viewer(id, entries, opts)
  end

  @spec stream_widget(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def stream_widget(id, entries, opts \\ []) do
    Operational.stream_widget(id, entries, opts)
  end

  @spec cluster_dashboard(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def cluster_dashboard(id, nodes, opts \\ []) do
    Operational.cluster_dashboard(id, nodes, opts)
  end

  @spec command_palette(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def command_palette(id, commands, opts \\ []) do
    Operational.command_palette(id, commands, opts)
  end

  @spec process_monitor(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def process_monitor(id, processes, opts \\ []) do
    Operational.process_monitor(id, processes, opts)
  end

  @spec container(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def container(id, children, opts \\ []) do
    Widget.new(:container,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      slot_children: %{default: children},
      styles: Builder.styles(opts)
    )
  end

  @spec column(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def column(id, children, opts \\ []) do
    Widget.new(:column,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      attributes: %{gap: Keyword.get(opts, :gap, :sm)},
      slot_children: %{default: children},
      styles: Builder.styles(opts)
    )
  end

  @spec row(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def row(id, children, opts \\ []) do
    Widget.new(:row,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      attributes: %{gap: Keyword.get(opts, :gap, :sm), direction: :horizontal},
      slot_children: %{default: children},
      styles: Builder.styles(opts)
    )
  end

  @spec stack(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def stack(id, children, opts \\ []) do
    Widget.new(:stack,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      attributes: %{
        gap: Keyword.get(opts, :gap, :sm),
        stacking: Keyword.get(opts, :stacking, :overlay)
      },
      slot_children: %{default: children},
      styles: Builder.styles(opts)
    )
  end

  @spec dialog(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def dialog(id, children, opts \\ []) do
    Widget.new(:dialog,
      id: id,
      family: :feedback,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      state: Builder.state(opts, %{open: Keyword.get(opts, :open, true)}),
      slot_children: %{content: children},
      events: Builder.events(dismiss: opts[:on_dismiss]),
      styles: Builder.styles(opts)
    )
  end
end
