defmodule TerminalUi.Widgets.Portable do
  @moduledoc """
  Terminal-native equivalents for promoted portable widgets.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder
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
        metadata(label, opts,
          role: :disclosure,
          focusable: true,
          native_surface: :portable_terminal_semantic,
          keyboard_hint: "space/enter",
          degradation_strategy: :inline_disclosure
        ),
      state:
        Builder.state(opts, %{
          open: option(opts, :open, false),
          expanded: option(opts, :open, false)
        }),
      attributes: %{
        label: label,
        content: label,
        content_label: option(opts, :content_label),
        summary: option(opts, :summary)
      },
      events: Builder.events(toggle: option(opts, :on_toggle)),
      styles: Builder.styles(opts)
    )
  end

  @spec kicker(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def kicker(id, value, opts \\ []) do
    Widget.new(:kicker,
      id: id,
      family: :semantic,
      metadata:
        metadata(value, opts,
          role: option(opts, :role, :eyebrow),
          native_surface: :portable_terminal_semantic
        ),
      attributes: %{
        value: value,
        content: value,
        icon: option(opts, :icon),
        role: option(opts, :role, :eyebrow),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec avatar(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def avatar(id, label, opts \\ []) do
    Widget.new(:avatar,
      id: id,
      family: :semantic,
      metadata:
        metadata(label, opts,
          role: :avatar,
          native_surface: :portable_terminal_semantic,
          degradation_strategy: :initials_text
        ),
      attributes: %{
        label: label,
        content: option(opts, :initials, label),
        initials: option(opts, :initials),
        source: option(opts, :source),
        status: option(opts, :status),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec presence_dot(String.t() | atom(), atom() | String.t(), keyword()) :: Widget.t()
  def presence_dot(id, status, opts \\ []) do
    Widget.new(:presence_dot,
      id: id,
      family: :semantic,
      metadata:
        metadata(to_string(status), opts,
          role: :presence_indicator,
          native_surface: :portable_terminal_semantic,
          degradation_strategy: :status_text
        ),
      state: Builder.state(opts, %{active: status in [:online, "online"]}),
      attributes: %{
        status: status,
        label: option(opts, :label),
        content: option(opts, :label, to_string(status)),
        pulse: option(opts, :pulse, false),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec segmented_button_group(String.t() | atom(), term(), keyword()) :: Widget.t()
  def segmented_button_group(id, items, opts \\ []) do
    Widget.new(:segmented_button_group,
      id: id,
      family: :semantic,
      metadata:
        metadata(to_string(id), opts,
          role: :segmented_control,
          focusable: true,
          native_surface: :portable_terminal_semantic,
          selection_mode: option(opts, :selection_mode, :single),
          keyboard_hint: "left/right/enter",
          degradation_strategy: :inline_menu_selection
        ),
      state: Builder.state(opts, %{active: not is_nil(option(opts, :active_item))}),
      bindings: Builder.bindings(opts, %{current: option(opts, :binding)}),
      attributes: %{
        items: normalize_items(items),
        active_item: option(opts, :active_item),
        selection_mode: option(opts, :selection_mode, :single),
        orientation: option(opts, :orientation, :horizontal),
        summary: option(opts, :summary)
      },
      events: Builder.events(select: option(opts, :on_select), change: option(opts, :on_change)),
      styles: Builder.styles(opts)
    )
  end

  @spec list_item_multi_column(String.t() | atom(), term(), keyword()) :: Widget.t()
  def list_item_multi_column(id, columns, opts \\ []) do
    Widget.new(:list_item_multi_column,
      id: id,
      family: :semantic,
      metadata:
        metadata(option(opts, :label, to_string(id)), opts,
          role: :list_item,
          focusable: option(opts, :focusable, false),
          native_surface: :portable_terminal_semantic,
          degradation_strategy: :linearized_row
        ),
      attributes: %{
        columns: normalize_items(columns),
        label: option(opts, :label),
        value: option(opts, :value),
        status: option(opts, :status),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec artifact_row(String.t() | atom(), term(), String.t(), keyword()) :: Widget.t()
  def artifact_row(id, artifact, title, opts \\ []) do
    Widget.new(:artifact_row,
      id: id,
      family: :semantic,
      metadata:
        metadata(title, opts,
          role: :artifact_row,
          focusable: true,
          native_surface: :portable_terminal_semantic,
          keyboard_hint: "enter",
          degradation_strategy: :linearized_row
        ),
      state: Builder.state(opts, %{selected: option(opts, :selected, false)}),
      attributes: %{
        artifact: artifact,
        title: title,
        label: title,
        content: title,
        status: option(opts, :status),
        timestamp: option(opts, :timestamp),
        summary: option(opts, :summary)
      },
      events:
        Builder.events(
          activate: option(opts, :on_activate, option(opts, :on_click)),
          select: option(opts, :on_select)
        ),
      styles: Builder.styles(opts)
    )
  end

  @spec sticky_header(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def sticky_header(id, title, opts \\ []) do
    Widget.new(:sticky_header,
      id: id,
      family: :semantic,
      metadata:
        metadata(title, opts,
          role: :sticky_header,
          native_surface: :portable_terminal_semantic,
          degradation_strategy: :inline_header
        ),
      state: Builder.state(opts, %{active: option(opts, :stuck, false)}),
      attributes: %{
        title: title,
        label: title,
        content: title,
        stuck: option(opts, :stuck, false),
        elevation: option(opts, :elevation),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec pipeline_stepper_horizontal(String.t() | atom(), term(), keyword()) :: Widget.t()
  def pipeline_stepper_horizontal(id, steps, opts \\ []) do
    Widget.new(:pipeline_stepper_horizontal,
      id: id,
      family: :workflow,
      metadata:
        metadata(to_string(id), opts,
          role: :pipeline_stepper,
          native_surface: :portable_terminal_workflow,
          degradation_strategy: :ascii_progress
        ),
      state: Builder.state(opts, %{active: not is_nil(option(opts, :active_item))}),
      attributes: %{
        steps: normalize_items(steps),
        active_item: option(opts, :active_item),
        status: option(opts, :status),
        orientation: :horizontal,
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec segmented_progress_bar(String.t() | atom(), term(), keyword()) :: Widget.t()
  def segmented_progress_bar(id, segments, opts \\ []) do
    Widget.new(:segmented_progress_bar,
      id: id,
      family: :workflow,
      metadata:
        metadata(option(opts, :label, to_string(id)), opts,
          role: :progress,
          native_surface: :portable_terminal_workflow,
          degradation_strategy: :ascii_progress
        ),
      state:
        Builder.state(opts, %{
          progress: option(opts, :current),
          loading: option(opts, :loading, false)
        }),
      attributes: %{
        segments: normalize_items(segments),
        current: option(opts, :current),
        maximum: option(opts, :maximum, 100),
        label: option(opts, :label),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec workflow_stage_list_vertical(String.t() | atom(), term(), keyword()) :: Widget.t()
  def workflow_stage_list_vertical(id, stages, opts \\ []) do
    Widget.new(:workflow_stage_list_vertical,
      id: id,
      family: :workflow,
      metadata:
        metadata(to_string(id), opts,
          role: :workflow_stage_list,
          native_surface: :portable_terminal_workflow,
          degradation_strategy: :linearized_list
        ),
      state: Builder.state(opts, %{active: not is_nil(option(opts, :active_item))}),
      attributes: %{
        stages: normalize_items(stages),
        active_item: option(opts, :active_item),
        status: option(opts, :status),
        orientation: :vertical,
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec meter_thin(String.t() | atom(), number(), keyword()) :: Widget.t()
  def meter_thin(id, current, opts \\ []) do
    Widget.new(:meter_thin,
      id: id,
      family: :workflow,
      metadata:
        metadata(option(opts, :label, to_string(id)), opts,
          role: :meter,
          native_surface: :portable_terminal_workflow,
          degradation_strategy: :ascii_progress
        ),
      state: Builder.state(opts, %{progress: current, severity: option(opts, :severity)}),
      attributes: %{
        current: current,
        minimum: option(opts, :minimum, 0),
        maximum: option(opts, :maximum, 100),
        label: option(opts, :label),
        severity: option(opts, :severity),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec slide_over_panel(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def slide_over_panel(id, children \\ [], opts \\ []) do
    Widget.new(:slide_over_panel,
      id: id,
      family: :workflow,
      metadata:
        metadata(option(opts, :title, to_string(id)), opts,
          role: :slide_over_panel,
          focusable: true,
          native_surface: :portable_terminal_workflow,
          overlay_role: :slide_over_panel,
          keyboard_hint: "esc/tab",
          degradation_strategy: :inline_overlay
        ),
      state:
        Builder.state(opts, %{
          open: option(opts, :visible, false),
          expanded: option(opts, :visible, false)
        }),
      attributes: %{
        title: option(opts, :title),
        label: option(opts, :title),
        placement: option(opts, :placement, :end),
        modal: option(opts, :modal, true),
        summary: option(opts, :summary)
      },
      slot_children: %{content: children},
      events: Builder.events(open: option(opts, :on_open), close: option(opts, :on_close)),
      styles: Builder.styles(opts)
    )
  end

  @spec event_callout(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def event_callout(id, message, opts \\ []) do
    Widget.new(:event_callout,
      id: id,
      family: :workflow,
      metadata:
        metadata(option(opts, :title, to_string(id)), opts,
          role: :event_callout,
          native_surface: :portable_terminal_workflow,
          degradation_strategy: :inline_feedback
        ),
      state: Builder.state(opts, %{severity: option(opts, :severity, :info)}),
      attributes: %{
        message: message,
        content: message,
        title: option(opts, :title),
        severity: option(opts, :severity, :info),
        timestamp: option(opts, :timestamp),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec redline_inline(String.t() | atom(), String.t(), String.t(), keyword()) :: Widget.t()
  def redline_inline(id, before_text, after_text, opts \\ []) do
    Widget.new(:redline_inline,
      id: id,
      family: :workflow,
      metadata:
        metadata(option(opts, :label, to_string(id)), opts,
          role: :redline,
          native_surface: :portable_terminal_workflow,
          degradation_strategy: :inline_diff
        ),
      attributes: %{
        before_text: before_text,
        after_text: after_text,
        content: "#{before_text} -> #{after_text}",
        label: option(opts, :label),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(opts)
    )
  end

  @spec code_block_syntax_highlighted(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def code_block_syntax_highlighted(id, code, opts \\ []) do
    Widget.new(:code_block_syntax_highlighted,
      id: id,
      family: :workflow,
      metadata:
        metadata(option(opts, :label, to_string(id)), opts,
          role: :code_block,
          native_surface: :portable_terminal_workflow,
          degradation_strategy: :plain_code_block
        ),
      attributes: %{
        code: code,
        content: code,
        language: option(opts, :language),
        label: option(opts, :label),
        wrap: option(opts, :wrap, false),
        summary: option(opts, :summary)
      },
      styles: Builder.styles(Keyword.put_new(opts, :glyph_set, :monospace))
    )
  end

  @spec chat_composer(String.t() | atom(), keyword()) :: Widget.t()
  def chat_composer(id, opts \\ []) do
    Widget.new(:chat_composer,
      id: id,
      family: :workflow,
      metadata:
        metadata(to_string(id), opts,
          role: :chat_composer,
          focusable: true,
          native_surface: :portable_terminal_workflow,
          keyboard_hint: "enter/ctrl-enter",
          degradation_strategy: :inline_text_prompt
        ),
      state: Builder.state(opts, %{active: option(opts, :editing, false)}),
      attributes: %{
        placeholder: option(opts, :placeholder),
        submit_intent: option(opts, :submit_intent),
        actions: normalize_items(option(opts, :actions, [])),
        attachments_supported?: option(opts, :attachments_supported?, false),
        multiline: option(opts, :multiline, true),
        summary: option(opts, :summary)
      },
      events: Builder.events(submit: option(opts, :on_submit), change: option(opts, :on_change)),
      styles: Builder.styles(opts)
    )
  end

  @spec host_form_shell(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def host_form_shell(id, children \\ [], opts \\ []) do
    Widget.new(:host_form_shell,
      id: id,
      family: :input,
      metadata:
        metadata(to_string(id), opts,
          role: :host_form_shell,
          focusable: true,
          native_surface: :portable_terminal_form,
          degradation_strategy: :linearized_form
        ),
      state:
        Builder.state(opts, %{
          loading: option(opts, :loading, false),
          phase: option(opts, :validation_status)
        }),
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
      events: Builder.events(submit: option(opts, :on_submit), change: option(opts, :on_change)),
      styles: Builder.styles(opts)
    )
  end

  @spec repeated_collection(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def repeated_collection(id, row_widgets, opts \\ []) do
    Widget.new(:repeated_collection,
      id: id,
      family: :collection,
      metadata:
        metadata(to_string(id), opts,
          role: :repeated_collection,
          focusable: option(opts, :focusable, false),
          native_surface: :portable_terminal_collection,
          degradation_strategy: :linearized_collection
        ),
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
      events: Builder.events(select: option(opts, :on_select), change: option(opts, :on_change)),
      styles: Builder.styles(opts)
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

  defp metadata(label, opts, defaults) do
    metadata_overrides =
      opts
      |> option(:metadata, %{})
      |> normalize_map()

    label
    |> Builder.metadata(opts, Map.new(defaults))
    |> Map.merge(metadata_overrides)
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

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp option(opts, key, default \\ nil) do
    Keyword.get(opts, key, default)
  end
end
