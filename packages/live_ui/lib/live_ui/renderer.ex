defmodule LiveUi.Renderer do
  @moduledoc """
  Package-facing entrypoint for canonical `UnifiedIUR` rendering.
  """

  use Phoenix.Component

  alias UnifiedIUR.{Binding, Element, Style}

  @spec accepts() :: module()
  def accepts, do: Element

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [:consume_canonical_iur, :reuse_native_widgets, :preserve_runtime_continuity]
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    [
      :alert_dialog,
      :bar_chart,
      :box,
      :button,
      :canvas,
      :checkbox,
      :cluster_dashboard,
      :column,
      :command_palette,
      :content,
      :context_menu,
      :date_input,
      :dialog,
      :field,
      :field_group,
      :file_input,
      :form_builder,
      :gauge,
      :grid,
      :icon,
      :image,
      :inline_feedback,
      :label,
      :line_chart,
      :link,
      :list,
      :log_viewer,
      :markdown_viewer,
      :menu,
      :numeric_input,
      :overlay,
      :pick_list,
      :process_monitor,
      :progress,
      :radio_group,
      :row,
      :scroll_bar,
      :select,
      :separator,
      :sparkline,
      :spacer,
      :split_pane,
      :status,
      :stream_widget,
      :supervision_tree_viewer,
      :table,
      :tabs,
      :text,
      :text_input,
      :time_input,
      :toast,
      :toggle,
      :tree_view,
      :viewport
    ]
  end

  attr(:element, :any, required: true)

  def render(%{element: %Element{kind: :text}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Text.render
      id={element_id(@element, "text")}
      content={content_text(@element)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :label}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Label.render
      id={element_id(@element, "label")}
      for={label_for(@element)}
      content={content_text(@element)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :icon}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Icon.render
      id={element_id(@element, "icon")}
      name={string_value(get_in(@element.attributes, [:icon, :name]), "icon")}
      set={string_optional(get_in(@element.attributes, [:icon, :set]))}
      fallback_text={string_optional(get_in(@element.attributes, [:icon, :fallback_text]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :image}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Image.render
      id={element_id(@element, "image")}
      src={string_value(get_in(@element.attributes, [:image, :source]), "")}
      alt={string_value(get_in(@element.attributes, [:image, :alt_text]), "")}
      fit={string_optional(get_in(@element.attributes, [:image, :fit]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :button}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Button.render
      id={element_id(@element, "button")}
      label={content_text(@element)}
      disabled={state_boolean(@element, :disabled?)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :link}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Link.render
      id={element_id(@element, "link")}
      label={content_text(@element)}
      href={string_value(get_in(@element.attributes, [:link, :target]), "#")}
      external={state_boolean(@element, [:link, :external?])}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :separator}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Separator.render
      id={element_id(@element, "separator")}
      orientation={string_value(get_in(@element.attributes, [:separator, :orientation]), "horizontal")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :spacer}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Spacer.render
      id={element_id(@element, "spacer")}
      size={string_value(get_in(@element.attributes, [:spacer, :size]), "md")}
      grow={integer_value(get_in(@element.attributes, [:spacer, :grow]), 0)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :content}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Content.render
      id={element_id(@element, "content")}
      role={string_value(get_in(@element.attributes, [:container, :role]), "content")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Widgets.Content.render>
    """
  end

  def render(%{element: %Element{kind: :box}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Box.render
      id={element_id(@element, "box")}
      padding={string_optional(get_in(@element.attributes, [:container, :padding]))}
      border={string_optional(get_in(@element.attributes, [:container, :border]))}
      background={string_optional(get_in(@element.attributes, [:container, :background]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Widgets.Box.render>
    """
  end

  def render(%{element: %Element{kind: :row}} = assigns) do
    ~H"""
    <LiveUi.Layout.Row.render
      id={element_id(@element, "row")}
      gap={string_optional(get_in(@element.attributes, [:layout, :gap]))}
      align={string_optional(get_in(@element.attributes, [:layout, :align]))}
      justify={string_optional(get_in(@element.attributes, [:layout, :justify]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Layout.Row.render>
    """
  end

  def render(%{element: %Element{kind: :column}} = assigns) do
    ~H"""
    <LiveUi.Layout.Column.render
      id={element_id(@element, "column")}
      gap={string_optional(get_in(@element.attributes, [:layout, :gap]))}
      align={string_optional(get_in(@element.attributes, [:layout, :align]))}
      justify={string_optional(get_in(@element.attributes, [:layout, :justify]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Layout.Column.render>
    """
  end

  def render(%{element: %Element{kind: :grid}} = assigns) do
    ~H"""
    <LiveUi.Layout.Grid.render
      id={element_id(@element, "grid")}
      columns={integer_optional(get_in(@element.attributes, [:layout, :columns]))}
      rows={integer_optional(get_in(@element.attributes, [:layout, :rows]))}
      gap={string_optional(get_in(@element.attributes, [:layout, :gap]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Layout.Grid.render>
    """
  end

  def render(%{element: %Element{kind: :form_builder}} = assigns) do
    ~H"""
    <LiveUi.Forms.FormBuilder.render
      id={element_id(@element, "form-builder")}
      autocomplete={boolean_default(get_in(@element.attributes, [:form, :autocomplete?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Forms.FormBuilder.render>
    """
  end

  def render(%{element: %Element{kind: :field_group}} = assigns) do
    ~H"""
    <LiveUi.Forms.FieldGroup.render
      id={element_id(@element, "field-group")}
      legend={string_optional(get_in(@element.attributes, [:group, :legend]))}
      description={string_optional(get_in(@element.attributes, [:group, :description]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Forms.FieldGroup.render>
    """
  end

  def render(%{element: %Element{kind: :field}} = assigns) do
    ~H"""
    <LiveUi.Forms.Field.render
      id={element_id(@element, "field")}
      name={string_optional(get_in(@element.attributes, [:field, :name]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <:label :for={child <- child_elements(@element, :label)}>
        <.render element={child} />
      </:label>
      <:control :for={child <- child_elements(@element, :control)}>
        <.render element={child} />
      </:control>
      <:help :for={child <- child_elements(@element, :help)}>
        <.render element={child} />
      </:help>
    </LiveUi.Forms.Field.render>
    """
  end

  def render(%{element: %Element{kind: kind}} = assigns)
      when kind in [:text_input, :numeric_input, :date_input, :time_input, :file_input] do
    ~H"""
    <LiveUi.Widgets.TextInput.render
      id={element_id(@element, "input")}
      name={binding_name(@element)}
      value={binding_value(@element)}
      placeholder={string_optional(get_in(@element.attributes, [:input, :placeholder]))}
      input_type={input_type(@element.kind)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: kind}} = assigns)
      when kind in [:toggle, :checkbox] do
    ~H"""
    <LiveUi.Widgets.Toggle.render
      id={element_id(@element, "toggle")}
      name={binding_name(@element)}
      checked={boolean_default(binding_value(@element), false)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: kind}} = assigns)
      when kind in [:select, :pick_list, :radio_group] do
    ~H"""
    <LiveUi.Widgets.Select.render
      id={element_id(@element, "select")}
      name={binding_name(@element)}
      options={selection_options(@element)}
      multiple={selection_multiple?(@element, @element.kind)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :menu}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Menu.render
      id={element_id(@element, "menu")}
      items={navigation_items(@element)}
      active_item={string_optional(get_in(@element.attributes, [:navigation, :active_item]))}
      orientation={string_value(get_in(@element.attributes, [:navigation, :orientation]), "vertical")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :tabs}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Tabs.render
      id={element_id(@element, "tabs")}
      items={navigation_items(@element)}
      active_item={string_optional(get_in(@element.attributes, [:navigation, :active_item]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :command_palette}} = assigns) do
    ~H"""
    <LiveUi.Widgets.CommandPalette.render
      id={element_id(@element, "command-palette")}
      query={string_optional(get_in(@element.attributes, [:command_palette, :query]))}
      items={command_palette_items(@element)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :list}} = assigns) do
    ~H"""
    <LiveUi.Widgets.List.render
      id={element_id(@element, "list")}
      items={list_items(@element)}
      ordered={boolean_default(get_in(@element.attributes, [:list, :ordered?]), false)}
      selection_mode={string_value(get_in(@element.attributes, [:list, :selection_mode]), "single")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :table}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Table.render
      id={element_id(@element, "table")}
      columns={get_in(@element.attributes, [:table, :columns]) || []}
      rows={get_in(@element.attributes, [:table, :rows]) || []}
      dense={boolean_default(get_in(@element.attributes, [:table, :dense?]), false)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :tree_view}} = assigns) do
    ~H"""
    <LiveUi.Widgets.TreeView.render
      id={element_id(@element, "tree-view")}
      nodes={get_in(@element.attributes, [:tree, :nodes]) || []}
      selection_mode={string_value(get_in(@element.attributes, [:tree, :selection_mode]), "single")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :status}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Status.render
      id={element_id(@element, "status")}
      text={string_value(get_in(@element.attributes, [:feedback, :text]), "")}
      severity={string_value(get_in(@element.attributes, [:feedback, :severity]), "info")}
      status={string_value(get_in(@element.attributes, [:feedback, :status]), "idle")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :progress}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Progress.render
      id={element_id(@element, "progress")}
      current={integer_value(get_in(@element.attributes, [:progress, :current]), 0)}
      total={integer_value(get_in(@element.attributes, [:progress, :total]), 100)}
      indeterminate={boolean_default(get_in(@element.attributes, [:progress, :indeterminate?]), false)}
      label={string_optional(get_in(@element.attributes, [:progress, :label]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :gauge}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Gauge.render
      id={element_id(@element, "gauge")}
      value={integer_value(get_in(@element.attributes, [:gauge, :value]), 0)}
      min={integer_value(get_in(@element.attributes, [:gauge, :min]), 0)}
      max={integer_value(get_in(@element.attributes, [:gauge, :max]), 100)}
      label={string_optional(get_in(@element.attributes, [:gauge, :label]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :inline_feedback}} = assigns) do
    ~H"""
    <LiveUi.Widgets.InlineFeedback.render
      id={element_id(@element, "inline-feedback")}
      message={string_value(get_in(@element.attributes, [:feedback, :message]), "")}
      title={string_optional(get_in(@element.attributes, [:feedback, :title]))}
      severity={string_value(get_in(@element.attributes, [:feedback, :severity]), "info")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :markdown_viewer}} = assigns) do
    ~H"""
    <LiveUi.Widgets.MarkdownViewer.render
      id={element_id(@element, "markdown-viewer")}
      source={string_value(get_in(@element.attributes, [:document, :source]), "")}
      mode={string_value(get_in(@element.attributes, [:document, :mode]), "rendered")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :log_viewer}} = assigns) do
    ~H"""
    <LiveUi.Widgets.LogViewer.render
      id={element_id(@element, "log-viewer")}
      entries={get_in(@element.attributes, [:logs, :entries]) || []}
      wrap={boolean_default(get_in(@element.attributes, [:logs, :wrap?]), true)}
      show_timestamps={boolean_default(get_in(@element.attributes, [:logs, :show_timestamps?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :stream_widget}} = assigns) do
    ~H"""
    <LiveUi.Widgets.StreamWidget.render
      id={element_id(@element, "stream-widget")}
      entries={get_in(@element.attributes, [:stream, :entries]) || []}
      ordering={string_value(get_in(@element.attributes, [:stream, :ordering]), "append_only")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :process_monitor}} = assigns) do
    ~H"""
    <LiveUi.Widgets.ProcessMonitor.render
      id={element_id(@element, "process-monitor")}
      processes={get_in(@element.attributes, [:monitor, :processes]) || []}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :cluster_dashboard}} = assigns) do
    ~H"""
    <LiveUi.Widgets.ClusterDashboard.render
      id={element_id(@element, "cluster-dashboard")}
      nodes={get_in(@element.attributes, [:cluster, :nodes]) || []}
      summary={get_in(@element.attributes, [:cluster, :summary]) || %{}}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :supervision_tree_viewer}} = assigns) do
    ~H"""
    <LiveUi.Widgets.SupervisionTreeViewer.render
      id={element_id(@element, "supervision-tree-viewer")}
      nodes={get_in(@element.attributes, [:inspection, :nodes]) || []}
      expanded={boolean_default(get_in(@element.attributes, [:inspection, :expanded?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :sparkline}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Sparkline.render
      id={element_id(@element, "sparkline")}
      series={chart_values(@element)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :bar_chart}} = assigns) do
    ~H"""
    <LiveUi.Widgets.BarChart.render
      id={element_id(@element, "bar-chart")}
      series={get_in(@element.attributes, [:chart, :series]) || []}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :line_chart}} = assigns) do
    ~H"""
    <LiveUi.Widgets.LineChart.render
      id={element_id(@element, "line-chart")}
      series={get_in(@element.attributes, [:chart, :series]) || []}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :dialog}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Dialog.render
      id={element_id(@element, "dialog")}
      title={string_optional(get_in(@element.attributes, [:dialog, :title]))}
      modal={boolean_default(get_in(@element.attributes, [:dialog, :modal?]), true)}
      dismissible={boolean_default(get_in(@element.attributes, [:dialog, :dismissible?]), true)}
      size={string_value(get_in(@element.attributes, [:dialog, :size]), "md")}
      background_fill={string_value(get_in(@element.attributes, [:dialog, :background_fill]), "scrim")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element, :content) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Widgets.Dialog.render>
    """
  end

  def render(%{element: %Element{kind: :alert_dialog}} = assigns) do
    ~H"""
    <LiveUi.Widgets.AlertDialog.render
      id={element_id(@element, "alert-dialog")}
      title={string_optional(get_in(@element.attributes, [:alert_dialog, :title]))}
      severity={string_value(get_in(@element.attributes, [:alert_dialog, :severity]), "warning")}
      requires_confirmation={boolean_default(get_in(@element.attributes, [:alert_dialog, :requires_confirmation?]), true)}
      background_fill={string_value(get_in(@element.attributes, [:alert_dialog, :background_fill]), "scrim")}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element, :content) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Widgets.AlertDialog.render>
    """
  end

  def render(%{element: %Element{kind: :toast}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Toast.render
      id={element_id(@element, "toast")}
      placement={placement_value(get_in(@element.attributes, [:toast, :placement]), "top-end")}
      duration_ms={integer_value(get_in(@element.attributes, [:toast, :duration_ms]), 5000)}
      severity={string_value(get_in(@element.attributes, [:toast, :severity]), "info")}
      transient={boolean_default(get_in(@element.attributes, [:toast, :transient?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element, :content) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Widgets.Toast.render>
    """
  end

  def render(%{element: %Element{kind: :context_menu}} = assigns) do
    ~H"""
    <LiveUi.Widgets.ContextMenu.render
      id={element_id(@element, "context-menu")}
      items={context_menu_items(@element)}
      placement={placement_value(get_in(@element.attributes, [:context_menu, :placement]), "bottom-start")}
      anchor={get_in(@element.attributes, [:context_menu, :anchor]) || %{}}
      active_item={string_optional(get_in(@element.attributes, [:context_menu, :active_item]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :overlay}} = assigns) do
    ~H"""
    <LiveUi.Widgets.OverlaySurface.render
      id={element_id(@element, "overlay-surface")}
      mode={string_value(get_in(@element.attributes, [:overlay, :mode]), "stacked")}
      background_fill={string_value(get_in(@element.attributes, [:overlay, :background_fill]), "transparent")}
      dismissible={boolean_default(get_in(@element.attributes, [:overlay, :dismissible?]), false)}
      focus_scope={string_optional(get_in(@element.attributes, [:overlay, :focus_scope]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <:base :for={child <- child_elements(@element, :base)}>
        <.render element={child} />
      </:base>
      <:overlay :for={child <- overlay_children(@element)}>
        <.render element={child} />
      </:overlay>
    </LiveUi.Widgets.OverlaySurface.render>
    """
  end

  def render(%{element: %Element{kind: :viewport}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Viewport.render
      id={element_id(@element, "viewport")}
      axis={string_value(get_in(@element.attributes, [:viewport, :axis]), "vertical")}
      offset_x={integer_value(get_in(@element.attributes, [:viewport, :offset, :x]), 0)}
      offset_y={integer_value(get_in(@element.attributes, [:viewport, :offset, :y]), 0)}
      clip={boolean_default(get_in(@element.attributes, [:viewport, :clip?]), true)}
      scrollbars={string_value(get_in(@element.attributes, [:viewport, :scrollbars]), "auto")}
      width={string_optional(get_in(@element.attributes, [:viewport, :width]))}
      height={string_optional(get_in(@element.attributes, [:viewport, :height]))}
      sync_group={string_optional(get_in(@element.attributes, [:viewport, :sync_group]))}
      independent_scroll={boolean_default(get_in(@element.attributes, [:viewport, :independent_scroll?]), false)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <%= for child <- child_elements(@element, :content) do %>
        <.render element={child} />
      <% end %>
    </LiveUi.Widgets.Viewport.render>
    """
  end

  def render(%{element: %Element{kind: :scroll_bar}} = assigns) do
    ~H"""
    <LiveUi.Widgets.ScrollBar.render
      id={element_id(@element, "scroll-bar")}
      orientation={string_value(get_in(@element.attributes, [:scroll_bar, :orientation]), "vertical")}
      position_start={float_value(get_in(@element.attributes, [:scroll_bar, :position, :start]), 0.0)}
      position_end={float_value(get_in(@element.attributes, [:scroll_bar, :position, :end]), 0.0)}
      viewport_size={integer_optional(get_in(@element.attributes, [:scroll_bar, :viewport_size]))}
      content_size={integer_optional(get_in(@element.attributes, [:scroll_bar, :content_size]))}
      viewport_ref={string_optional(get_in(@element.attributes, [:scroll_bar, :viewport_ref]))}
      sync_group={string_optional(get_in(@element.attributes, [:scroll_bar, :sync_group]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(%{element: %Element{kind: :split_pane}} = assigns) do
    ~H"""
    <LiveUi.Widgets.SplitPane.render
      id={element_id(@element, "split-pane")}
      direction={string_value(get_in(@element.attributes, [:split, :direction]), "horizontal")}
      ratio={float_value(get_in(@element.attributes, [:split, :ratio]), 0.5)}
      resizable={boolean_default(get_in(@element.attributes, [:split, :resizable?]), true)}
      min_primary={integer_optional(get_in(@element.attributes, [:split, :min_primary]))}
      min_secondary={integer_optional(get_in(@element.attributes, [:split, :min_secondary]))}
      divider_size={integer_optional(get_in(@element.attributes, [:split, :divider, :size]))}
      sync_scroll={string_optional(get_in(@element.attributes, [:split, :sync_scroll]))}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    >
      <:primary :for={child <- child_elements(@element, :primary)}>
        <.render element={child} />
      </:primary>
      <:secondary :for={child <- child_elements(@element, :secondary)}>
        <.render element={child} />
      </:secondary>
    </LiveUi.Widgets.SplitPane.render>
    """
  end

  def render(%{element: %Element{kind: :canvas}} = assigns) do
    ~H"""
    <LiveUi.Widgets.Canvas.render
      id={element_id(@element, "canvas")}
      operations={get_in(@element.attributes, [:canvas, :operations]) || []}
      width={integer_optional(get_in(@element.attributes, [:canvas, :width]))}
      height={integer_optional(get_in(@element.attributes, [:canvas, :height]))}
      unit={string_value(get_in(@element.attributes, [:canvas, :unit]), "cell")}
      background={string_optional(get_in(@element.attributes, [:canvas, :background]))}
      clip={boolean_default(get_in(@element.attributes, [:canvas, :clip?]), true)}
      tone={style_tone(@element)}
      variant={theme_variant(@element)}
    />
    """
  end

  def render(assigns) do
    ~H"""
    <div id={element_id(@element, "unsupported")} data-live-ui-widget="unsupported" data-live-ui-kind={to_string(@element.kind)}>
      Unsupported canonical kind: <%= inspect(@element.kind) %>
    </div>
    """
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__

  defp child_elements(%Element{} = element, slot \\ :default) do
    element
    |> Element.children_for_slot(slot)
    |> Enum.map(& &1.element)
    |> Enum.reject(&is_nil/1)
  end

  defp overlay_children(%Element{} = element) do
    element.children
    |> Enum.reject(&(&1.slot == :base))
    |> Enum.map(& &1.element)
    |> Enum.reject(&is_nil/1)
  end

  defp binding_name(%Element{} = element) do
    element
    |> primary_binding()
    |> case do
      %Binding{name: nil, path: [segment | _]} -> to_string(segment)
      %Binding{name: name} when not is_nil(name) -> to_string(name)
      _ -> element_id(element, "binding")
    end
  end

  defp binding_value(%Element{} = element) do
    case primary_binding(element) do
      %Binding{value: nil, default: default} -> default
      %Binding{value: value} -> value
      _ -> nil
    end
  end

  defp primary_binding(%Element{} = element) do
    element.attributes
    |> Map.get(:bindings, [])
    |> List.wrap()
    |> List.first()
  end

  defp selection_options(%Element{} = element) do
    element.attributes
    |> get_in([:selection, :options])
    |> List.wrap()
    |> Enum.map(fn option ->
      %{
        id: Map.get(option, :id) || Map.get(option, "id"),
        value: Map.get(option, :value) || Map.get(option, "value"),
        label: Map.get(option, :label) || Map.get(option, "label"),
        disabled: Map.get(option, :disabled?) || Map.get(option, "disabled?"),
        selected: Map.get(option, :selected?) || Map.get(option, "selected?")
      }
    end)
  end

  defp selection_multiple?(%Element{} = element, kind) do
    case kind do
      :radio_group -> false
      _ -> boolean_default(get_in(element.attributes, [:selection, :multiple?]), false)
    end
  end

  defp list_items(%Element{} = element) do
    get_in(element.attributes, [:list, :items]) || []
  end

  defp navigation_items(%Element{} = element) do
    get_in(element.attributes, [:navigation, :items]) || []
  end

  defp command_palette_items(%Element{} = element) do
    active_command = get_in(element.attributes, [:command_palette, :active_command])

    element
    |> get_in([Access.key(:attributes), :command_palette, :commands])
    |> List.wrap()
    |> Enum.map(fn command ->
      command = Map.new(command)
      command_id = Map.get(command, :id) || Map.get(command, "id")

      Map.put(command, :active, command_id == active_command)
    end)
  end

  defp context_menu_items(%Element{} = element) do
    element
    |> child_elements(:menu)
    |> List.first()
    |> case do
      %Element{} = menu -> navigation_items(menu)
      _ -> []
    end
  end

  defp chart_values(%Element{} = element) do
    case get_in(element.attributes, [:chart, :series]) || [] do
      [series | _] -> Map.get(series, :values) || Map.get(series, "values") || []
      _ -> []
    end
  end

  defp theme_variant(%Element{} = element) do
    element.attributes
    |> Map.get(:theme)
    |> case do
      %{variant: variant} -> string_optional(variant)
      %{"variant" => variant} -> string_optional(variant)
      _ -> nil
    end
  end

  defp style_tone(%Element{} = element) do
    case Map.get(element.attributes, :style) do
      %Style{emphasis: emphasis} ->
        string_optional(Map.get(emphasis, :tone) || Map.get(emphasis, "tone"))

      %{emphasis: emphasis} when is_map(emphasis) ->
        string_optional(Map.get(emphasis, :tone) || Map.get(emphasis, "tone"))

      _ ->
        nil
    end
  end

  defp content_text(%Element{} = element) do
    string_value(get_in(element.attributes, [:content, :text]), "")
  end

  defp label_for(%Element{} = element) do
    string_optional(get_in(element.attributes, [:label, :for]))
  end

  defp input_type(:text_input), do: "text"
  defp input_type(:numeric_input), do: "number"
  defp input_type(:date_input), do: "date"
  defp input_type(:time_input), do: "time"
  defp input_type(:file_input), do: "file"

  defp element_id(%Element{id: nil}, fallback), do: fallback
  defp element_id(%Element{id: id}, _fallback), do: to_string(id)

  defp string_value(nil, default), do: default
  defp string_value(value, _default), do: to_string(value)

  defp string_optional(nil), do: nil
  defp string_optional(value), do: to_string(value)

  defp placement_value(nil, default), do: default

  defp placement_value(value, _default) do
    value
    |> to_string()
    |> String.replace("_", "-")
  end

  defp integer_optional(nil), do: nil
  defp integer_optional(value) when is_integer(value), do: value
  defp integer_optional(value) when is_float(value), do: trunc(value)
  defp integer_optional(value) when is_binary(value), do: String.to_integer(value)

  defp integer_value(nil, default), do: default
  defp integer_value(value, _default) when is_integer(value), do: value
  defp integer_value(value, _default) when is_float(value), do: trunc(value)
  defp integer_value(value, _default) when is_binary(value), do: String.to_integer(value)

  defp float_value(nil, default), do: default
  defp float_value(value, _default) when is_float(value), do: value
  defp float_value(value, _default) when is_integer(value), do: value / 1

  defp float_value(value, default) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> number
      _ -> default
    end
  end

  defp boolean_default(nil, default), do: default
  defp boolean_default(value, _default) when is_boolean(value), do: value
  defp boolean_default("true", _default), do: true
  defp boolean_default("false", _default), do: false
  defp boolean_default(value, _default), do: value

  defp state_boolean(%Element{} = element, path) when is_list(path) do
    boolean_default(get_in(element.attributes, path), false)
  end

  defp state_boolean(%Element{} = element, key) do
    boolean_default(get_in(element.attributes, [:state, key]), false)
  end
end
