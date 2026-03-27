defmodule Demo.Screens do
  @moduledoc """
  Screen registry for the desktop_ui demo application.

  This module registers all widget screens that can be navigated to
  in the demo application.
  """

  @behaviour DesktopUi.Navigation.Registry

  # Widget categories and their widgets
  @widget_categories %{
    content: [
      {:button, "Button", "Clickable action button"},
      {:text, "Text", "Static text display"},
      {:icon, "Icon", "Iconographic symbol"},
      {:image, "Image", "Image display"},
      {:label, "Label", "Form field label"},
      {:link, "Link", "Navigation link"},
      {:separator, "Separator", "Visual separator"},
      {:spacer, "Spacer", "Flexible spacing"}
    ],
    layout: [
      {:box, "Box", "Flexible container"},
      {:content, "Content", "Content wrapper"},
      {:row, "Row", "Horizontal layout"},
      {:column, "Column", "Vertical layout"},
      {:grid, "Grid", "Grid layout"}
    ],
    forms: [
      {:form_builder, "Form Builder", "Form construction"},
      {:field_group, "Field Group", "Field grouping"},
      {:field, "Field", "Form field"}
    ],
    input: [
      {:text_input, "Text Input", "Text entry field"},
      {:numeric_input, "Numeric Input", "Number entry"},
      {:toggle, "Toggle", "Toggle switch"},
      {:checkbox, "Checkbox", "Check box"},
      {:radio_group, "Radio Group", "Radio buttons"},
      {:select, "Select", "Dropdown selection"},
      {:pick_list, "Pick List", "Selection list"},
      {:date_input, "Date Input", "Date picker"},
      {:time_input, "Time Input", "Time picker"},
      {:file_input, "File Input", "File selection"}
    ],
    navigation: [
      {:menu, "Menu", "Dropdown menu"},
      {:tabs, "Tabs", "Tab navigation"},
      {:breadcrumbs, "Breadcrumbs", "Breadcrumb trail"},
      {:list, "List", "List navigation"}
    ],
    data: [
      {:table, "Table", "Data table"},
      {:tree_view, "Tree View", "Hierarchical data"},
      {:markdown_viewer, "Markdown", "Markdown display"},
      {:log_viewer, "Log Viewer", "Log display"}
    ],
    feedback: [
      {:status, "Status", "Status indicator"},
      {:progress, "Progress", "Progress bar"},
      {:gauge, "Gauge", "Gauge/meter"},
      {:sparkline, "Sparkline", "Mini chart"},
      {:bar_chart, "Bar Chart", "Bar graph"},
      {:line_chart, "Line Chart", "Line graph"}
    ],
    display: [
      {:viewport, "Viewport", "Scrollable area"},
      {:scroll_bar, "Scroll Bar", "Scrollbar"},
      {:split_pane, "Split Pane", "Split view"},
      {:canvas, "Canvas", "Drawing surface"}
    ],
    overlay: [
      {:overlay, "Overlay", "Overlay layer"},
      {:dialog, "Dialog", "Modal dialog"},
      {:alert_dialog, "Alert Dialog", "Alert modal"},
      {:context_menu, "Context Menu", "Contextual menu"},
      {:toast, "Toast", "Notification"}
    ],
    operational: [
      {:stream_widget, "Stream", "Data stream"},
      {:process_monitor, "Process Monitor", "Process view"},
      {:supervision_tree, "Supervision Tree", "Supervisor tree"},
      {:cluster_dashboard, "Cluster", "Cluster view"}
    ]
  }

  @all_widgets Enum.flat_map(@widget_categories, fn {_cat, widgets} -> widgets end)

  @impl true
  def register do
    %{
      home: {Demo.Screens.Home, title: "Home", icon: :home, category: nil},
      button: {Demo.Screens.WidgetScreen, title: "Button", icon: :button, category: :content},
      text: {Demo.Screens.WidgetScreen, title: "Text", icon: :text, category: :content},
      icon: {Demo.Screens.WidgetScreen, title: "Icon", icon: :icon, category: :content},
      image: {Demo.Screens.WidgetScreen, title: "Image", icon: :image, category: :content},
      label: {Demo.Screens.WidgetScreen, title: "Label", icon: :label, category: :content},
      link: {Demo.Screens.WidgetScreen, title: "Link", icon: :link, category: :content},
      separator: {Demo.Screens.WidgetScreen, title: "Separator", icon: :separator, category: :content},
      spacer: {Demo.Screens.WidgetScreen, title: "Spacer", icon: :spacer, category: :content},
      box: {Demo.Screens.WidgetScreen, title: "Box", icon: :box, category: :layout},
      content: {Demo.Screens.WidgetScreen, title: "Content", icon: :content, category: :layout},
      row: {Demo.Screens.WidgetScreen, title: "Row", icon: :row, category: :layout},
      column: {Demo.Screens.WidgetScreen, title: "Column", icon: :column, category: :layout},
      grid: {Demo.Screens.WidgetScreen, title: "Grid", icon: :grid, category: :layout},
      form_builder: {Demo.Screens.WidgetScreen, title: "Form Builder", icon: :form, category: :forms},
      field_group: {Demo.Screens.WidgetScreen, title: "Field Group", icon: :group, category: :forms},
      field: {Demo.Screens.WidgetScreen, title: "Field", icon: :field, category: :forms},
      text_input: {Demo.Screens.WidgetScreen, title: "Text Input", icon: :text_input, category: :input},
      numeric_input: {Demo.Screens.WidgetScreen, title: "Numeric Input", icon: :numeric, category: :input},
      toggle: {Demo.Screens.WidgetScreen, title: "Toggle", icon: :toggle, category: :input},
      checkbox: {Demo.Screens.WidgetScreen, title: "Checkbox", icon: :checkbox, category: :input},
      radio_group: {Demo.Screens.WidgetScreen, title: "Radio Group", icon: :radio, category: :input},
      select: {Demo.Screens.WidgetScreen, title: "Select", icon: :select, category: :input},
      pick_list: {Demo.Screens.WidgetScreen, title: "Pick List", icon: :list, category: :input},
      date_input: {Demo.Screens.WidgetScreen, title: "Date Input", icon: :calendar, category: :input},
      time_input: {Demo.Screens.WidgetScreen, title: "Time Input", icon: :clock, category: :input},
      file_input: {Demo.Screens.WidgetScreen, title: "File Input", icon: :file, category: :input},
      menu: {Demo.Screens.WidgetScreen, title: "Menu", icon: :menu, category: :navigation},
      tabs: {Demo.Screens.WidgetScreen, title: "Tabs", icon: :tabs, category: :navigation},
      breadcrumbs: {Demo.Screens.WidgetScreen, title: "Breadcrumbs", icon: :breadcrumbs, category: :navigation},
      list: {Demo.Screens.WidgetScreen, title: "List", icon: :list, category: :navigation},
      table: {Demo.Screens.WidgetScreen, title: "Table", icon: :table, category: :data},
      tree_view: {Demo.Screens.WidgetScreen, title: "Tree View", icon: :tree, category: :data},
      markdown_viewer: {Demo.Screens.WidgetScreen, title: "Markdown", icon: :markdown, category: :data},
      log_viewer: {Demo.Screens.WidgetScreen, title: "Log Viewer", icon: :log, category: :data},
      status: {Demo.Screens.WidgetScreen, title: "Status", icon: :status, category: :feedback},
      progress: {Demo.Screens.WidgetScreen, title: "Progress", icon: :progress, category: :feedback},
      gauge: {Demo.Screens.WidgetScreen, title: "Gauge", icon: :gauge, category: :feedback},
      sparkline: {Demo.Screens.WidgetScreen, title: "Sparkline", icon: :sparkline, category: :feedback},
      bar_chart: {Demo.Screens.WidgetScreen, title: "Bar Chart", icon: :chart, category: :feedback},
      line_chart: {Demo.Screens.WidgetScreen, title: "Line Chart", icon: :chart_line, category: :feedback},
      viewport: {Demo.Screens.WidgetScreen, title: "Viewport", icon: :viewport, category: :display},
      scroll_bar: {Demo.Screens.WidgetScreen, title: "Scroll Bar", icon: :scroll, category: :display},
      split_pane: {Demo.Screens.WidgetScreen, title: "Split Pane", icon: :columns, category: :display},
      canvas: {Demo.Screens.WidgetScreen, title: "Canvas", icon: :canvas, category: :display},
      overlay: {Demo.Screens.WidgetScreen, title: "Overlay", icon: :overlay, category: :overlay},
      dialog: {Demo.Screens.WidgetScreen, title: "Dialog", icon: :dialog, category: :overlay},
      alert_dialog: {Demo.Screens.WidgetScreen, title: "Alert Dialog", icon: :alert, category: :overlay},
      context_menu: {Demo.Screens.WidgetScreen, title: "Context Menu", icon: :context_menu, category: :overlay},
      toast: {Demo.Screens.WidgetScreen, title: "Toast", icon: :notification, category: :overlay},
      stream_widget: {Demo.Screens.WidgetScreen, title: "Stream", icon: :stream, category: :operational},
      process_monitor: {Demo.Screens.WidgetScreen, title: "Process Monitor", icon: :monitor, category: :operational},
      supervision_tree: {Demo.Screens.WidgetScreen, title: "Supervision Tree", icon: :tree, category: :operational},
      cluster_dashboard: {Demo.Screens.WidgetScreen, title: "Cluster", icon: :cluster, category: :operational}
    }
  end

  @impl true
  def get_screen(:home), do: Demo.Screens.Home

  def get_screen(widget_id) when is_atom(widget_id) do
    case Map.get(register(), widget_id) do
      {module, _opts} -> module
      nil -> Demo.Screens.WidgetScreen
    end
  end

  def get_screen(_), do: nil

  @impl true
  def screen_metadata(:home) do
    %{
      title: "Home",
      icon: :home,
      appears_in_history?: true,
      modal_only?: false
    }
  end

  def screen_metadata(widget_id) when is_atom(widget_id) do
    case Map.get(register(), widget_id) do
      {_module, opts} ->
        %{
          title: Keyword.get(opts, :title),
          icon: Keyword.get(opts, :icon),
          appears_in_history?: true,
          modal_only?: false,
          category: Keyword.get(opts, :category)
        }

      nil ->
        %{}
    end
  end

  def screen_metadata(_), do: %{}

  @doc """
  Get all widgets for a given category.
  """
  def widgets_for_category(category) when is_atom(category) do
    Map.get(@widget_categories, category, [])
  end

  @doc """
  Get all categories.
  """
  def categories do
    Map.keys(@widget_categories)
  end

  @doc """
  Get all widgets.
  """
  def all_widgets, do: @all_widgets
end
