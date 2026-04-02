defmodule LiveUi.Demo.WidgetPreview do
  @moduledoc false

  use Phoenix.Component

  alias LiveUi.Demo.Style

  attr(:example, :map, required: true)

  @sample_image_uri "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='240' height='140' viewBox='0 0 240 140'><rect width='240' height='140' rx='16' fill='%23131d31'/><circle cx='58' cy='46' r='18' fill='%232563eb'/><path d='M34 114L86 62l28 28 20-20 38 44H34z' fill='%23059669'/><rect x='122' y='28' width='80' height='12' rx='6' fill='%23f9fafb' opacity='0.86'/><rect x='122' y='52' width='62' height='10' rx='5' fill='%23f9fafb' opacity='0.6'/></svg>"

  def render(assigns) do
    assigns =
      assigns
      |> assign(:id_base, "live-ui-demo-widget-#{assigns.example.id}")
      |> assign(:panel_style, Style.direct(:box, variant: :panel))
      |> assign(:title_style, Style.direct(:text, tone: :accent))

    ~H"""
    <LiveUi.Widgets.Box.render
      id={sample_id(@id_base, "panel")}
      padding="lg"
      border="subtle"
      background="panel"
      {@panel_style}
    >
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "title")}
        content="Widget Preview"
        {@title_style}
      />
      <%= preview(assigns) %>
    </LiveUi.Widgets.Box.render>
    """
  end

  defp preview(%{example: %{id: :text}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:text, tone: :accent))

    ~H"""
    <LiveUi.Widgets.Text.render
      id={sample_id(@id_base, "text")}
      content="Text widgets carry tone through the shared live_ui theme."
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :label}} = assigns) do
    assigns =
      assigns
      |> assign(:label_style, Style.direct(:label))
      |> assign(:input_style, Style.direct(:text_input, variant: :filled))

    ~H"""
    <LiveUi.Layout.Column.render id={sample_id(@id_base, "column")} gap="sm">
      <LiveUi.Widgets.Label.render
        id={sample_id(@id_base, "label")}
        for={sample_id(@id_base, "input")}
        content="Profile name"
        {@label_style}
      />
      <LiveUi.Widgets.TextInput.render
        id={sample_id(@id_base, "input")}
        name="profile_name"
        value="Pascal"
        placeholder="Profile name"
        {@input_style}
      />
    </LiveUi.Layout.Column.render>
    """
  end

  defp preview(%{example: %{id: :image}} = assigns) do
    assigns =
      assigns
      |> assign(:style, Style.direct(:image))
      |> assign(:sample_image_uri, @sample_image_uri)

    ~H"""
    <LiveUi.Widgets.Image.render
      id={sample_id(@id_base, "image")}
      src={@sample_image_uri}
      alt="Sample dashboard artwork"
      fit="cover"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :icon}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:icon, tone: :accent))

    ~H"""
    <LiveUi.Widgets.Icon.render
      id={sample_id(@id_base, "icon")}
      name="spark"
      fallback_text="spark"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :button}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:button, variant: :quiet))

    ~H"""
    <LiveUi.Widgets.Button.render
      id={sample_id(@id_base, "button")}
      label="Run Widget Action"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :link}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:link, tone: :accent))

    ~H"""
    <LiveUi.Widgets.Link.render
      id={sample_id(@id_base, "link")}
      label="Open widget docs"
      href="#"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :separator}} = assigns) do
    assigns =
      assigns
      |> assign(:text_style, Style.direct(:text))
      |> assign(:separator_style, Style.direct(:separator))

    ~H"""
    <LiveUi.Layout.Column.render id={sample_id(@id_base, "column")} gap="sm">
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "top")}
        content="Primary section"
        {@text_style}
      />
      <LiveUi.Widgets.Separator.render
        id={sample_id(@id_base, "separator")}
        orientation="horizontal"
        {@separator_style}
      />
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "bottom")}
        content="Secondary section"
        {@text_style}
      />
    </LiveUi.Layout.Column.render>
    """
  end

  defp preview(%{example: %{id: :spacer}} = assigns) do
    assigns =
      assigns
      |> assign(:text_style, Style.direct(:text))
      |> assign(:spacer_style, Style.direct(:spacer))

    ~H"""
    <LiveUi.Layout.Row.render id={sample_id(@id_base, "row")} gap="sm">
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "left")}
        content="Leading"
        {@text_style}
      />
      <LiveUi.Widgets.Spacer.render
        id={sample_id(@id_base, "spacer")}
        size="lg"
        grow={1}
        {@spacer_style}
      />
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "right")}
        content="Trailing"
        {@text_style}
      />
    </LiveUi.Layout.Row.render>
    """
  end

  defp preview(%{example: %{id: :content}} = assigns) do
    assigns =
      assigns
      |> assign(:content_style, Style.direct(:content))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.Content.render
      id={sample_id(@id_base, "content")}
      role="content"
      {@content_style}
    >
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "text")}
        content="Content wraps arbitrary body copy inside one reusable widget surface."
        {@text_style}
      />
    </LiveUi.Widgets.Content.render>
    """
  end

  defp preview(%{example: %{id: :container}} = assigns) do
    assigns =
      assigns
      |> assign(:container_style, Style.direct(:container))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.Container.render
      id={sample_id(@id_base, "container")}
      role="preview"
      {@container_style}
    >
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "text")}
        content="Container groups inner content while preserving one outer boundary."
        {@text_style}
      />
    </LiveUi.Widgets.Container.render>
    """
  end

  defp preview(%{example: %{id: :box}} = assigns) do
    assigns =
      assigns
      |> assign(:box_style, Style.direct(:box, variant: :panel))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.Box.render
      id={sample_id(@id_base, "box")}
      padding="lg"
      border="subtle"
      background="panel"
      {@box_style}
    >
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "text")}
        content="Box creates a framed panel with padding, border, and themed surface treatment."
        {@text_style}
      />
    </LiveUi.Widgets.Box.render>
    """
  end

  defp preview(%{example: %{id: :screen_shell}} = assigns) do
    assigns =
      assigns
      |> assign(:shell_style, Style.direct(:screen_shell, variant: :workspace))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.ScreenShell.render
      id={sample_id(@id_base, "shell")}
      title="Widget Workspace"
      {@shell_style}
    >
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "text")}
        content="ScreenShell frames a whole screen with its own title and content region."
        {@text_style}
      />
    </LiveUi.Widgets.ScreenShell.render>
    """
  end

  defp preview(%{example: %{id: :text_input}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:text_input, variant: :filled))

    ~H"""
    <LiveUi.Widgets.TextInput.render
      id={sample_id(@id_base, "text-input")}
      name="widget_name"
      value="Live UI"
      placeholder="Widget name"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :toggle}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:toggle))

    ~H"""
    <LiveUi.Widgets.Toggle.render
      id={sample_id(@id_base, "toggle")}
      name="widget_enabled"
      checked={true}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :select}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:select))

    ~H"""
    <LiveUi.Widgets.Select.render
      id={sample_id(@id_base, "select")}
      name="widget_category"
      options={[
        %{value: "foundational", label: "Foundational"},
        %{value: "display", label: "Display", selected: true},
        %{value: "overlay", label: "Overlay"}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :menu}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:menu))

    ~H"""
    <LiveUi.Widgets.Menu.render
      id={sample_id(@id_base, "menu")}
      orientation="vertical"
      active_item="insights"
      items={[
        %{id: "overview", label: "Overview"},
        %{id: "insights", label: "Insights"},
        %{id: "settings", label: "Settings"}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :tabs}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:tabs))

    ~H"""
    <LiveUi.Widgets.Tabs.render
      id={sample_id(@id_base, "tabs")}
      active_item="surface"
      items={[
        %{id: "surface", label: "Surface"},
        %{id: "state", label: "State"},
        %{id: "signals", label: "Signals"}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :command_palette}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:command_palette))

    ~H"""
    <LiveUi.Widgets.CommandPalette.render
      id={sample_id(@id_base, "command-palette")}
      query="wid"
      items={[
        %{id: "widgets", label: "Open widgets", active: true},
        %{id: "workspace", label: "Toggle workspace"},
        %{id: "validate", label: "Run validation"}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :list}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:list))

    ~H"""
    <LiveUi.Widgets.List.render
      id={sample_id(@id_base, "list")}
      selection_mode="single"
      items={[
        %{id: "button", label: "Button", description: "Primary action surface", selected: true},
        %{id: "tabs", label: "Tabs", description: "Section navigation"},
        %{id: "toast", label: "Toast", description: "Transient feedback"}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :table}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:table))

    ~H"""
    <LiveUi.Widgets.Table.render
      id={sample_id(@id_base, "table")}
      columns={[
        %{id: "widget", label: "Widget"},
        %{id: "family", label: "Family"},
        %{id: "events", label: "Events"}
      ]}
      rows={[
        %{id: "button", cells: ["Button", "Content", "Click"]},
        %{id: "tabs", cells: ["Tabs", "Navigation", "Navigate"]},
        %{id: "toast", cells: ["Toast", "Overlay", "None"]}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :tree_view}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:tree_view))

    ~H"""
    <LiveUi.Widgets.TreeView.render
      id={sample_id(@id_base, "tree-view")}
      nodes={[
        %{
          id: "widgets",
          label: "Widgets",
          expanded: true,
          children: [
            %{id: "content", label: "Content"},
            %{id: "overlay", label: "Overlay", selected: true}
          ]
        }
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :markdown_viewer}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:markdown_viewer))

    ~H"""
    <LiveUi.Widgets.MarkdownViewer.render
      id={sample_id(@id_base, "markdown")}
      source={"# Widget Notes\n\n- Built with `live_ui`\n- Styled through the shared theme\n- Rendered as a static preview"}
      mode="rendered"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :log_viewer}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:log_viewer))

    ~H"""
    <LiveUi.Widgets.LogViewer.render
      id={sample_id(@id_base, "log-viewer")}
      entries={[
        %{id: "1", timestamp: "10:41:02", severity: "info", message: "Mounted widget preview"},
        %{id: "2", timestamp: "10:41:04", severity: "success", message: "Resolved style profile"},
        %{id: "3", timestamp: "10:41:06", severity: "warning", message: "No event handlers attached"}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :status}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:status))

    ~H"""
    <LiveUi.Widgets.Status.render
      id={sample_id(@id_base, "status")}
      text="Ready for review"
      severity="success"
      status="healthy"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :progress}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:progress))

    ~H"""
    <LiveUi.Widgets.Progress.render
      id={sample_id(@id_base, "progress")}
      current={68}
      total={100}
      label="Widget coverage"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :gauge}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:gauge))

    ~H"""
    <LiveUi.Widgets.Gauge.render
      id={sample_id(@id_base, "gauge")}
      value={72}
      min={0}
      max={100}
      label="Health"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :inline_feedback}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:inline_feedback))

    ~H"""
    <LiveUi.Widgets.InlineFeedback.render
      id={sample_id(@id_base, "inline-feedback")}
      title="Heads up"
      message="This widget preview is intentionally static."
      severity="info"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :sparkline}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:sparkline))

    ~H"""
    <LiveUi.Widgets.Sparkline.render
      id={sample_id(@id_base, "sparkline")}
      series={[4, 6, 5, 8, 9, 7]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :bar_chart}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:bar_chart))

    ~H"""
    <LiveUi.Widgets.BarChart.render
      id={sample_id(@id_base, "bar-chart")}
      series={[%{label: "A", value: 4}, %{label: "B", value: 8}, %{label: "C", value: 6}]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :line_chart}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:line_chart))

    ~H"""
    <LiveUi.Widgets.LineChart.render
      id={sample_id(@id_base, "line-chart")}
      series={[%{x: 1, y: 2}, %{x: 2, y: 5}, %{x: 3, y: 4}, %{x: 4, y: 8}]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :stream_widget}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:stream_widget))

    ~H"""
    <LiveUi.Widgets.StreamWidget.render
      id={sample_id(@id_base, "stream-widget")}
      ordering="append_only"
      entries={[
        %{id: "1", severity: "info", message: "Preview mounted"},
        %{id: "2", severity: "success", message: "Theme resolved"},
        %{id: "3", severity: "warning", message: "Static mode enabled"}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :process_monitor}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:process_monitor))

    ~H"""
    <LiveUi.Widgets.ProcessMonitor.render
      id={sample_id(@id_base, "process-monitor")}
      processes={[
        %{id: "ui", pid: "#PID<0.321.0>", state: :running},
        %{id: "theme", pid: "#PID<0.322.0>", state: :idle},
        %{id: "preview", pid: "#PID<0.323.0>", state: :waiting}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :supervision_tree_viewer}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:supervision_tree_viewer))

    ~H"""
    <LiveUi.Widgets.SupervisionTreeViewer.render
      id={sample_id(@id_base, "supervision-tree")}
      expanded={true}
      nodes={[
        %{
          id: "root",
          label: "LiveUi.Demo.Supervisor",
          type: "supervisor",
          status: "up",
          children: [
            %{id: "server", label: "PreviewServer", type: "worker", status: "up"},
            %{id: "theme", label: "ThemeCache", type: "worker", status: "up"}
          ]
        }
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :cluster_dashboard}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:cluster_dashboard))

    ~H"""
    <LiveUi.Widgets.ClusterDashboard.render
      id={sample_id(@id_base, "cluster-dashboard")}
      summary={%{healthy: 2, degraded: 1}}
      nodes={[
        %{id: "node-a", status: "healthy"},
        %{id: "node-b", status: "healthy"},
        %{id: "node-c", status: "degraded"}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :overlay_surface}} = assigns) do
    assigns =
      assigns
      |> assign(:surface_style, Style.direct(:overlay_surface, variant: :modal))
      |> assign(:box_style, Style.direct(:box, variant: :panel))
      |> assign(:toast_style, Style.direct(:toast, state: :active))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.OverlaySurface.render
      id={sample_id(@id_base, "overlay-surface")}
      mode="stacked"
      background_fill="transparent"
      dismissible={false}
      {@surface_style}
    >
      <:base>
        <LiveUi.Widgets.Box.render
          id={sample_id(@id_base, "overlay-base")}
          padding="md"
          border="subtle"
          background="panel"
          {@box_style}
        >
          <LiveUi.Widgets.Text.render
            id={sample_id(@id_base, "overlay-base-text")}
            content="Base workspace content"
            {@text_style}
          />
        </LiveUi.Widgets.Box.render>
      </:base>
      <:overlay>
        <LiveUi.Widgets.Toast.render
          id={sample_id(@id_base, "overlay-toast")}
          severity="info"
          state="active"
          {@toast_style}
        >
          <LiveUi.Widgets.Text.render
            id={sample_id(@id_base, "overlay-toast-text")}
            content="Overlay surface can present layered feedback."
            {@text_style}
          />
        </LiveUi.Widgets.Toast.render>
      </:overlay>
    </LiveUi.Widgets.OverlaySurface.render>
    """
  end

  defp preview(%{example: %{id: :dialog}} = assigns) do
    assigns =
      assigns
      |> assign(:style, Style.direct(:dialog, variant: :modal))
      |> assign(:button_style, Style.direct(:button, variant: :quiet))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.Dialog.render
      id={sample_id(@id_base, "dialog")}
      title="Review widget changes"
      open={true}
      modal={false}
      dismissible={true}
      size="md"
      background_fill="transparent"
      {@style}
    >
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "dialog-text")}
        content="Dialogs group content and actions inside a focused overlay surface."
        {@text_style}
      />
      <:actions>
        <LiveUi.Widgets.Button.render
          id={sample_id(@id_base, "dialog-action")}
          label="Dismiss"
          {@button_style}
        />
      </:actions>
    </LiveUi.Widgets.Dialog.render>
    """
  end

  defp preview(%{example: %{id: :alert_dialog}} = assigns) do
    assigns =
      assigns
      |> assign(:style, Style.direct(:alert_dialog))
      |> assign(:button_style, Style.direct(:button, variant: :quiet))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.AlertDialog.render
      id={sample_id(@id_base, "alert-dialog")}
      title="Delete preview?"
      severity="warning"
      open={true}
      requires_confirmation={true}
      background_fill="transparent"
      {@style}
    >
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "alert-dialog-text")}
        content="Alert dialogs emphasize sensitive actions that need confirmation."
        {@text_style}
      />
      <:actions>
        <LiveUi.Widgets.Button.render
          id={sample_id(@id_base, "alert-dialog-action")}
          label="Keep widget"
          {@button_style}
        />
      </:actions>
    </LiveUi.Widgets.AlertDialog.render>
    """
  end

  defp preview(%{example: %{id: :context_menu}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:context_menu))

    ~H"""
    <LiveUi.Widgets.ContextMenu.render
      id={sample_id(@id_base, "context-menu")}
      open={true}
      placement="bottom-start"
      active_item="duplicate"
      anchor={%{x: 24, y: 12}}
      items={[
        %{id: "open", label: "Open"},
        %{id: "duplicate", label: "Duplicate"},
        %{id: "archive", label: "Archive"}
      ]}
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :toast}} = assigns) do
    assigns =
      assigns
      |> assign(:style, Style.direct(:toast, state: :active))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.Toast.render
      id={sample_id(@id_base, "toast")}
      open={true}
      placement="top-end"
      duration_ms={3000}
      severity="success"
      state="active"
      {@style}
    >
      <LiveUi.Widgets.Text.render
        id={sample_id(@id_base, "toast-text")}
        content="Widget preview saved"
        {@text_style}
      />
    </LiveUi.Widgets.Toast.render>
    """
  end

  defp preview(%{example: %{id: :viewport}} = assigns) do
    assigns =
      assigns
      |> assign(:style, Style.direct(:viewport))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.Viewport.render
      id={sample_id(@id_base, "viewport")}
      axis="vertical"
      offset_y={12}
      scrollbars="auto"
      width="100%"
      height="12rem"
      {@style}
    >
      <LiveUi.Layout.Column.render id={sample_id(@id_base, "viewport-column")} gap="sm">
        <%= for index <- 1..6 do %>
          <LiveUi.Widgets.Text.render
            id={sample_id(@id_base, "viewport-line-#{index}")}
            content={"Viewport row #{index}"}
            {@text_style}
          />
        <% end %>
      </LiveUi.Layout.Column.render>
    </LiveUi.Widgets.Viewport.render>
    """
  end

  defp preview(%{example: %{id: :scroll_bar}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:scroll_bar))

    ~H"""
    <LiveUi.Widgets.ScrollBar.render
      id={sample_id(@id_base, "scroll-bar")}
      orientation="vertical"
      position_start={0.15}
      position_end={0.55}
      viewport_size={240}
      content_size={720}
      viewport_ref="preview-viewport"
      {@style}
    />
    """
  end

  defp preview(%{example: %{id: :split_pane}} = assigns) do
    assigns =
      assigns
      |> assign(:style, Style.direct(:split_pane))
      |> assign(:box_style, Style.direct(:box, variant: :panel))
      |> assign(:text_style, Style.direct(:text))

    ~H"""
    <LiveUi.Widgets.SplitPane.render
      id={sample_id(@id_base, "split-pane")}
      direction="horizontal"
      ratio={0.45}
      resizable={true}
      {@style}
    >
      <:primary>
        <LiveUi.Widgets.Box.render
          id={sample_id(@id_base, "split-primary")}
          padding="md"
          border="subtle"
          background="panel"
          {@box_style}
        >
          <LiveUi.Widgets.Text.render
            id={sample_id(@id_base, "split-primary-text")}
            content="Primary pane"
            {@text_style}
          />
        </LiveUi.Widgets.Box.render>
      </:primary>
      <:secondary>
        <LiveUi.Widgets.Box.render
          id={sample_id(@id_base, "split-secondary")}
          padding="md"
          border="subtle"
          background="panel"
          {@box_style}
        >
          <LiveUi.Widgets.Text.render
            id={sample_id(@id_base, "split-secondary-text")}
            content="Secondary pane"
            {@text_style}
          />
        </LiveUi.Widgets.Box.render>
      </:secondary>
    </LiveUi.Widgets.SplitPane.render>
    """
  end

  defp preview(%{example: %{id: :canvas}} = assigns) do
    assigns = assign(assigns, :style, Style.direct(:canvas, variant: :analysis))

    ~H"""
    <LiveUi.Widgets.Canvas.render
      id={sample_id(@id_base, "canvas")}
      width={48}
      height={12}
      unit="cell"
      background="analysis"
      operations={[
        %{kind: "text", position: %{x: 2, y: 2}, text: "Live UI"},
        %{kind: "text", position: %{x: 2, y: 5}, text: "Canvas preview"},
        %{kind: "text", position: %{x: 2, y: 8}, text: "48 x 12 cells"}
      ]}
      {@style}
    />
    """
  end

  defp sample_id(base, suffix), do: "#{base}-#{suffix}"
end
