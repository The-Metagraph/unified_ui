defmodule UnifiedExamples.Demo.WidgetInfo do
  @moduledoc """
  Widget metadata catalog for the demo application.
  Auto-extracts information from LiveUI component metadata.
  """

  alias UnifiedExamples.Shared.Catalog
  alias LiveUi.Component

  @widget_modules %{
    # Content
    button: LiveUi.Widgets.Button,
    text: LiveUi.Widgets.Text,
    label: LiveUi.Widgets.Label,
    link: LiveUi.Widgets.Link,
    icon: LiveUi.Widgets.Icon,
    image: LiveUi.Widgets.Image,
    separator: LiveUi.Widgets.Separator,
    spacer: LiveUi.Widgets.Spacer,
    # Input
    text_input: LiveUi.Widgets.TextInput,
    numeric_input: nil, # TODO: add to LiveUI
    checkbox: nil,
    radio_group: LiveUi.Widgets.RadioButton,
    select: LiveUi.Widgets.Select,
    toggle: LiveUi.Widgets.Toggle,
    date_input: nil,
    time_input: nil,
    file_input: nil,
    pick_list: nil,
    # Forms
    field: LiveUi.Widgets.Field,
    field_group: LiveUi.Widgets.FieldGroup,
    form_builder: LiveUi.Widgets.FormBuilder,
    # Navigation
    menu: LiveUi.Widgets.Menu,
    tabs: LiveUi.Widgets.Tabs,
    command_palette: LiveUi.Widgets.CommandPalette,
    list: LiveUi.Widgets.List,
    # Layout
    box: LiveUi.Widgets.Box,
    row: LiveUi.Widgets.Row,
    column: LiveUi.Widgets.Column,
    grid: LiveUi.Widgets.Grid,
    canvas: LiveUi.Widgets.Canvas,
    viewport: LiveUi.Widgets.Viewport,
    scroll_bar: LiveUi.Widgets.ScrollBar,
    split_pane: LiveUi.Widgets.SplitPane,
    # Data
    table: LiveUi.Widgets.Table,
    tree_view: LiveUi.Widgets.TreeView,
    markdown_viewer: LiveUi.Widgets.MarkdownViewer,
    log_viewer: LiveUi.Widgets.LogViewer,
    # Feedback
    status: LiveUi.Widgets.Status,
    progress: LiveUi.Widgets.Progress,
    gauge: LiveUi.Widgets.Gauge,
    inline_feedback: LiveUi.Widgets.InlineFeedback,
    sparkline: LiveUi.Widgets.Sparkline,
    bar_chart: LiveUi.Widgets.BarChart,
    line_chart: LiveUi.Widgets.LineChart,
    # Overlays
    overlay: LiveUi.Widgets.Overlay,
    dialog: LiveUi.Widgets.Dialog,
    alert_dialog: LiveUi.Widgets.AlertDialog,
    context_menu: LiveUi.Widgets.ContextMenu,
    toast: LiveUi.Widgets.Toast,
    # Operational
    stream_widget: LiveUi.Widgets.StreamWidget,
    process_monitor: LiveUi.Widgets.ProcessMonitor,
    supervision_tree_viewer: LiveUi.Widgets.SupervisionTreeViewer,
    cluster_dashboard: LiveUi.Widgets.ClusterDashboard
  }

  @spec list_widgets() :: [%{name: atom(), module: module()}]
  def list_widgets do
    @widget_modules
    |> Enum.map(fn {name, module} ->
      %{
        name: name,
        module: module,
        available?: not is_nil(module)
      }
    end)
    |> Enum.filter(& &1.available?)
  end

  @spec widget_info(atom()) :: map()
  def widget_info(widget_name) when is_atom(widget_name) do
    module = Map.get(@widget_modules, widget_name)

    if is_nil(module) do
      %{
        name: widget_name,
        description: "Widget not yet implemented in LiveUI",
        events: [],
        attributes: []
      }
    else
      metadata = Component.metadata(module)

      %{
        name: widget_name,
        module: module,
        description: get_moduledoc(module),
        family: metadata.metadata.family,
        events: extract_events(metadata),
        attributes: extract_attributes(metadata)
      }
    end
  end

  @spec widgets_for_category(atom()) :: [map()]
  def widgets_for_category(category_id) do
    Catalog.by_family()
    |> Map.get(category_id, [])
    |> Enum.map(fn entry ->
      widget_info(entry.widget)
      |> Map.put(:directory, entry.directory)
    end)
  end

  defp get_moduledoc(module) do
    case Code.fetch_docs(module) do
      {:docs_v1, _anno, _lang, _format, _moduledoc, _metadata, docs} ->
        # Find the moduledoc (usually the first entry with :moduledoc kind)
        Enum.find_value(docs, fn
          {:moduledoc, _line, _doc_format, doc_string, _metadata} -> doc_string
          _ -> nil
        end) || "No description available."

      _ ->
        "No description available."
    end
  end

  defp extract_events(metadata) do
    events = metadata.metadata.events || []

    Enum.map(events, fn event ->
      {event, event_info(event)}
    end)
  end

  defp event_info(:click), do: "Triggered when user clicks the element"
  defp event_info(:change), do: "Triggered when value changes"
  defp event_info(:submit), do: "Triggered when form is submitted"
  defp event_info(:navigate), do: "Triggered for navigation actions"
  defp event_info(event), do: "Custom event: #{event}"

  defp extract_attributes(metadata) do
    assigns = metadata.metadata.assigns || []

    Enum.map(assigns, fn attr ->
      attr_name = attr |> to_string() |> String.trim_leading(":")

      {attr_name, %{
        type: infer_type(attr),
        required?: attr in metadata.metadata.required_assigns || []
      }}
    end)
  end

  defp infer_type(:disabled), do: "boolean"
  defp infer_type(:label), do: "string"
  defp infer_type(:content), do: "string"
  defp infer_type(:id), do: "string"
  defp infer_type(:class), do: "string"
  defp infer_type(:tone), do: "string (accent|muted|...)"
  defp infer_type(:variant), do: "string (solid|quiet|...)"
  defp infer_type(:state), do: "string (default|...)"
  defp infer_type(:rest), do: "global HTML attributes"
  defp infer_type(:metadata), do: "map"
  defp infer_type(_), do: "any"
end
