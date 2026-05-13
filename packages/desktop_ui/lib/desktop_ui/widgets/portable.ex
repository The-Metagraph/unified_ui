defmodule DesktopUi.Widgets.Portable do
  @moduledoc """
  Desktop-native equivalents for promoted portable widgets.
  """

  alias DesktopUi.Widget
  alias UnifiedIUR.Binding

  @semantic_kinds [
    :disclosure,
    :kicker,
    :avatar,
    :presence_dot,
    :segmented_button_group,
    :list_item_multi_column,
    :artifact_row,
    :sticky_header
  ]

  @workflow_kinds [
    :pipeline_stepper_horizontal,
    :segmented_progress_bar,
    :workflow_stage_list_vertical,
    :meter_thin,
    :slide_over_panel,
    :event_callout,
    :redline_inline,
    :code_block_syntax_highlighted,
    :chat_composer
  ]

  @form_kinds [:host_form_shell]
  @collection_kinds [:repeated_collection]

  @spec kinds() :: [atom()]
  def kinds, do: @semantic_kinds ++ @workflow_kinds ++ @form_kinds ++ @collection_kinds

  @spec semantic_kinds() :: [atom()]
  def semantic_kinds, do: @semantic_kinds

  @spec workflow_kinds() :: [atom()]
  def workflow_kinds, do: @workflow_kinds

  @spec form_kinds() :: [atom()]
  def form_kinds, do: @form_kinds

  @spec collection_kinds() :: [atom()]
  def collection_kinds, do: @collection_kinds

  @spec disclosure(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def disclosure(id, label, opts \\ []) do
    Widget.new(:disclosure,
      id: id,
      family: :semantic,
      metadata:
        metadata(opts,
          role: :disclosure,
          focusable: true,
          native_surface: :portable_semantic,
          keyboard: [:space, :enter],
          pointer: [:click]
        ),
      state: state(opts, open: option(opts, :open, false), expanded: option(opts, :open, false)),
      attributes: %{
        label: label,
        content_label: option(opts, :content_label),
        summary: option(opts, :summary)
      },
      events: events(toggle: option(opts, :on_toggle)),
      styles: styles(opts)
    )
  end

  @spec kicker(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def kicker(id, value, opts \\ []) do
    Widget.new(:kicker,
      id: id,
      family: :semantic,
      metadata:
        metadata(opts, role: :kicker, focusable: false, native_surface: :portable_semantic),
      state: state(opts),
      attributes: %{
        value: value,
        content: value,
        icon: option(opts, :icon),
        role: option(opts, :role, :eyebrow),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec avatar(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def avatar(id, label, opts \\ []) do
    Widget.new(:avatar,
      id: id,
      family: :semantic,
      metadata:
        metadata(opts, role: :avatar, focusable: false, native_surface: :portable_semantic),
      state: state(opts),
      attributes: %{
        label: label,
        content: option(opts, :initials, label),
        initials: option(opts, :initials),
        source: option(opts, :source),
        status: option(opts, :status),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec presence_dot(String.t() | atom(), atom() | String.t(), keyword()) :: Widget.t()
  def presence_dot(id, status, opts \\ []) do
    Widget.new(:presence_dot,
      id: id,
      family: :semantic,
      metadata:
        metadata(opts,
          role: :presence_indicator,
          focusable: false,
          native_surface: :portable_semantic
        ),
      state: state(opts, active: status in [:online, "online"]),
      attributes: %{
        status: status,
        label: option(opts, :label),
        pulse: option(opts, :pulse, false),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec segmented_button_group(String.t() | atom(), term(), keyword()) :: Widget.t()
  def segmented_button_group(id, items, opts \\ []) do
    Widget.new(:segmented_button_group,
      id: id,
      family: :semantic,
      metadata:
        metadata(opts,
          role: :segmented_control,
          focusable: true,
          native_surface: :portable_semantic,
          selection_mode: option(opts, :selection_mode, :single),
          keyboard: [:arrow_left, :arrow_right, :space],
          pointer: [:click]
        ),
      state: state(opts, active: not is_nil(option(opts, :active_item))),
      attributes: %{
        items: normalize_items(items),
        active_item: option(opts, :active_item),
        selection_mode: option(opts, :selection_mode, :single),
        orientation: option(opts, :orientation, :horizontal),
        summary: option(opts, :summary)
      },
      events: events(selection: option(opts, :on_select), change: option(opts, :on_change)),
      styles: styles(opts)
    )
  end

  @spec list_item_multi_column(String.t() | atom(), term(), keyword()) :: Widget.t()
  def list_item_multi_column(id, columns, opts \\ []) do
    Widget.new(:list_item_multi_column,
      id: id,
      family: :semantic,
      metadata:
        metadata(opts,
          role: :list_item,
          focusable: option(opts, :focusable, false),
          native_surface: :portable_semantic
        ),
      state: state(opts),
      attributes: %{
        columns: normalize_items(columns),
        label: option(opts, :label),
        value: option(opts, :value),
        status: option(opts, :status),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec artifact_row(String.t() | atom(), term(), String.t(), keyword()) :: Widget.t()
  def artifact_row(id, artifact, title, opts \\ []) do
    Widget.new(:artifact_row,
      id: id,
      family: :semantic,
      metadata:
        metadata(opts,
          role: :artifact_row,
          focusable: true,
          native_surface: :portable_semantic,
          keyboard: [:enter],
          pointer: [:click]
        ),
      state: state(opts, selected: option(opts, :selected, false)),
      attributes: %{
        artifact: artifact,
        title: title,
        label: title,
        status: option(opts, :status),
        timestamp: option(opts, :timestamp),
        summary: option(opts, :summary)
      },
      events: events(click: option(opts, :on_click), selection: option(opts, :on_select)),
      styles: styles(opts)
    )
  end

  @spec sticky_header(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def sticky_header(id, title, opts \\ []) do
    Widget.new(:sticky_header,
      id: id,
      family: :semantic,
      metadata:
        metadata(opts,
          role: :sticky_header,
          focusable: false,
          native_surface: :portable_semantic
        ),
      state: state(opts, active: option(opts, :stuck, false)),
      attributes: %{
        title: title,
        label: title,
        stuck: option(opts, :stuck, false),
        elevation: option(opts, :elevation),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec pipeline_stepper_horizontal(String.t() | atom(), term(), keyword()) :: Widget.t()
  def pipeline_stepper_horizontal(id, steps, opts \\ []) do
    Widget.new(:pipeline_stepper_horizontal,
      id: id,
      family: :workflow,
      metadata: metadata(opts, role: :pipeline_stepper, native_surface: :portable_workflow),
      state: state(opts, active: not is_nil(option(opts, :active_item))),
      attributes: %{
        steps: normalize_items(steps),
        active_item: option(opts, :active_item),
        status: option(opts, :status),
        orientation: :horizontal,
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec segmented_progress_bar(String.t() | atom(), term(), keyword()) :: Widget.t()
  def segmented_progress_bar(id, segments, opts \\ []) do
    Widget.new(:segmented_progress_bar,
      id: id,
      family: :workflow,
      metadata: metadata(opts, role: :progress, native_surface: :portable_workflow),
      state:
        state(opts, progress: option(opts, :current), loading: option(opts, :loading, false)),
      attributes: %{
        segments: normalize_items(segments),
        current: option(opts, :current),
        maximum: option(opts, :maximum, 100),
        label: option(opts, :label),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec workflow_stage_list_vertical(String.t() | atom(), term(), keyword()) :: Widget.t()
  def workflow_stage_list_vertical(id, stages, opts \\ []) do
    Widget.new(:workflow_stage_list_vertical,
      id: id,
      family: :workflow,
      metadata: metadata(opts, role: :workflow_stage_list, native_surface: :portable_workflow),
      state: state(opts, active: not is_nil(option(opts, :active_item))),
      attributes: %{
        stages: normalize_items(stages),
        active_item: option(opts, :active_item),
        status: option(opts, :status),
        orientation: :vertical,
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec meter_thin(String.t() | atom(), number(), keyword()) :: Widget.t()
  def meter_thin(id, current, opts \\ []) do
    Widget.new(:meter_thin,
      id: id,
      family: :workflow,
      metadata: metadata(opts, role: :meter, native_surface: :portable_workflow),
      state: state(opts, progress: current, severity: option(opts, :severity)),
      attributes: %{
        current: current,
        minimum: option(opts, :minimum, 0),
        maximum: option(opts, :maximum, 100),
        label: option(opts, :label),
        severity: option(opts, :severity),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec slide_over_panel(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def slide_over_panel(id, children \\ [], opts \\ []) do
    Widget.new(:slide_over_panel,
      id: id,
      family: :workflow,
      metadata:
        metadata(opts,
          role: :slide_over_panel,
          focusable: true,
          native_surface: :portable_workflow,
          overlay_role: :slide_over_panel,
          overlay_lifecycle: :managed,
          z_order: option(opts, :z_order, :overlay),
          keyboard: [:escape, :tab],
          pointer: [:click_outside]
        ),
      state:
        state(opts, open: option(opts, :visible, false), expanded: option(opts, :visible, false)),
      attributes: %{
        title: option(opts, :title),
        label: option(opts, :title),
        placement: option(opts, :placement, :end),
        modal: option(opts, :modal, true),
        summary: option(opts, :summary)
      },
      slot_children: %{content: children},
      events: events(open: option(opts, :on_open), close: option(opts, :on_close)),
      styles: styles(opts)
    )
  end

  @spec event_callout(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def event_callout(id, message, opts \\ []) do
    Widget.new(:event_callout,
      id: id,
      family: :workflow,
      metadata: metadata(opts, role: :event_callout, native_surface: :portable_workflow),
      state: state(opts, severity: option(opts, :severity, :info)),
      attributes: %{
        message: message,
        title: option(opts, :title),
        severity: option(opts, :severity, :info),
        timestamp: option(opts, :timestamp),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec redline_inline(String.t() | atom(), String.t(), String.t(), keyword()) :: Widget.t()
  def redline_inline(id, before_text, after_text, opts \\ []) do
    Widget.new(:redline_inline,
      id: id,
      family: :workflow,
      metadata: metadata(opts, role: :redline, native_surface: :portable_workflow),
      state: state(opts),
      attributes: %{
        before_text: before_text,
        after_text: after_text,
        label: option(opts, :label),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec code_block_syntax_highlighted(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def code_block_syntax_highlighted(id, code, opts \\ []) do
    Widget.new(:code_block_syntax_highlighted,
      id: id,
      family: :workflow,
      metadata:
        metadata(opts,
          role: :code_block,
          native_surface: :portable_workflow,
          text_rendering: :monospace
        ),
      state: state(opts),
      attributes: %{
        code: code,
        content: code,
        language: option(opts, :language),
        label: option(opts, :label),
        wrap: option(opts, :wrap, false),
        summary: option(opts, :summary)
      },
      styles: styles(opts)
    )
  end

  @spec chat_composer(String.t() | atom(), keyword()) :: Widget.t()
  def chat_composer(id, opts \\ []) do
    Widget.new(:chat_composer,
      id: id,
      family: :workflow,
      metadata:
        metadata(opts,
          role: :chat_composer,
          focusable: true,
          native_surface: :portable_workflow,
          keyboard: [:enter, :mod_enter],
          pointer: [:button_click]
        ),
      state: state(opts, active: option(opts, :editing, false)),
      attributes: %{
        placeholder: option(opts, :placeholder),
        submit_intent: option(opts, :submit_intent),
        actions: normalize_items(option(opts, :actions, [])),
        multiline: option(opts, :multiline, true),
        summary: option(opts, :summary)
      },
      events: events(submit: option(opts, :on_submit), change: option(opts, :on_change)),
      styles: styles(opts)
    )
  end

  @spec host_form_shell(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def host_form_shell(id, children \\ [], opts \\ []) do
    Widget.new(:host_form_shell,
      id: id,
      family: :input,
      metadata:
        metadata(opts,
          role: :host_form_shell,
          focusable: true,
          native_surface: :portable_form,
          host_owned?: true
        ),
      state:
        state(opts,
          loading: option(opts, :loading, false),
          phase: option(opts, :validation_status)
        ),
      attributes: %{
        owner: option(opts, :owner, :host),
        lifecycle: option(opts, :lifecycle, :host_owned),
        action_placement: option(opts, :action_placement, :footer),
        mode: option(opts, :mode, :host_owned),
        submit_intent: option(opts, :submit_intent),
        autocomplete: option(opts, :autocomplete, true),
        validation_summary: option(opts, :validation_summary),
        validation_errors: List.wrap(option(opts, :validation_errors, []))
      },
      slot_children: %{
        default: children,
        fields: List.wrap(option(opts, :fields, [])),
        actions: List.wrap(option(opts, :actions_slot, []))
      },
      events: events(submit: option(opts, :on_submit), change: option(opts, :on_change)),
      styles: styles(opts)
    )
  end

  @spec repeated_collection(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def repeated_collection(id, row_widgets, opts \\ []) do
    Widget.new(:repeated_collection,
      id: id,
      family: :collection,
      metadata:
        metadata(opts,
          role: :repeated_collection,
          focusable: option(opts, :focusable, false),
          native_surface: :portable_collection,
          row_scope?: true
        ),
      state: state(opts),
      attributes: %{
        item_alias: option(opts, :item_alias, :item),
        index_alias: option(opts, :index_alias, :index),
        key_path: option(opts, :key_path, []),
        rows: option(opts, :row_metadata, []),
        empty_state: option(opts, :empty_state, [])
      },
      slot_children: %{
        row: row_widgets,
        empty_state: List.wrap(option(opts, :empty_state, []))
      },
      events: events(selection: option(opts, :on_select), change: option(opts, :on_change)),
      styles: styles(opts)
    )
  end

  @spec normalize_items(term()) :: [map()]
  def normalize_items(nil), do: []

  def normalize_items(%Binding{} = binding) do
    [%{id: "binding", label: text(binding), value: binding}]
  end

  def normalize_items(items) when is_map(items) do
    items
    |> Map.to_list()
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> normalize_items()
  end

  def normalize_items(items) when is_list(items) do
    Enum.map(items, fn
      {id, value} ->
        %{id: id, label: text(value), value: value}

      item when is_map(item) ->
        %{
          id: field(item, :id, field(item, :value, field(item, :label, "item"))),
          label: field(item, :label, field(item, :value, field(item, :id, "Item"))),
          value: field(item, :value, item)
        }

      item ->
        %{id: item, label: text(item), value: item}
    end)
  end

  def normalize_items(item), do: [%{id: "value", label: text(item), value: item}]

  defp metadata(opts, defaults) do
    defaults
    |> Keyword.merge(Keyword.get(opts, :metadata, []))
    |> Map.new()
  end

  defp state(opts, defaults \\ []) do
    defaults
    |> Keyword.merge(disabled: option(opts, :disabled, false), focused: false)
    |> Map.new()
  end

  defp styles(opts), do: Map.new(Keyword.get(opts, :styles, []))

  defp events(entries) do
    entries
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Map.new()
  end

  defp field(map, key, default) when is_map(map) do
    Map.get(map, key, Map.get(map, to_string(key), default))
  end

  defp text(nil), do: ""
  defp text(%Binding{} = binding), do: row_binding_text(binding)
  defp text(value) when is_binary(value), do: value
  defp text(value) when is_atom(value), do: Atom.to_string(value)
  defp text(value) when is_number(value), do: to_string(value)
  defp text(value), do: inspect(value)

  defp row_binding_text(%Binding{source: :row_scope, scope: scope, path: path}) do
    "row:" <>
      ([scope, path]
       |> List.flatten()
       |> Enum.map(&to_string/1)
       |> Enum.join("."))
  end

  defp row_binding_text(%Binding{name: name, path: path}) do
    "binding:" <>
      ([name, path]
       |> List.flatten()
       |> Enum.reject(&is_nil/1)
       |> Enum.map(&to_string/1)
       |> Enum.join("."))
  end

  defp option(opts, key, default \\ nil) do
    Keyword.get(opts, key, default)
  end
end
