defmodule ElmUi.Widgets.Portable do
  @moduledoc """
  Promoted portable widget constructors for the Phoenix-and-Elm runtime.
  """

  alias ElmUi.Widgets.Builder

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

  @spec kinds() :: [atom()]
  def kinds, do: @semantic_kinds ++ @workflow_kinds

  @spec semantic_kinds() :: [atom()]
  def semantic_kinds, do: @semantic_kinds

  @spec workflow_kinds() :: [atom()]
  def workflow_kinds, do: @workflow_kinds

  @spec disclosure(String.t() | atom(), String.t(), keyword() | map()) :: ElmUi.Widget.t()
  def disclosure(id, label, opts \\ []) when is_binary(label) do
    opts = options(id, opts)

    widget(:disclosure, opts,
      attributes: %{
        label: label,
        content_label: Builder.option(opts, :content_label),
        summary: Builder.option(opts, :summary)
      },
      state: state(opts, [:disabled, :focused, :open], open: option(opts, :open, false)),
      events: Builder.events(opts, on_toggle: :change),
      metadata: %{native_surface: :portable_semantic, expandable?: true}
    )
  end

  @spec kicker(String.t() | atom(), String.t(), keyword() | map()) :: ElmUi.Widget.t()
  def kicker(id, value, opts \\ []) when is_binary(value) do
    opts = options(id, opts)

    widget(:kicker, opts,
      attributes: %{
        value: value,
        icon: Builder.option(opts, :icon),
        role: Builder.option(opts, :role, :eyebrow),
        summary: Builder.option(opts, :summary)
      },
      metadata: %{native_surface: :portable_semantic}
    )
  end

  @spec avatar(String.t() | atom(), String.t(), keyword() | map()) :: ElmUi.Widget.t()
  def avatar(id, label, opts \\ []) when is_binary(label) do
    opts = options(id, opts)

    widget(:avatar, opts,
      attributes: %{
        label: label,
        initials: Builder.option(opts, :initials),
        source: option(opts, :source, Builder.option(opts, :avatar_source)),
        status: Builder.option(opts, :status),
        summary: Builder.option(opts, :summary)
      },
      metadata: %{native_surface: :portable_semantic}
    )
  end

  @spec presence_dot(String.t() | atom(), atom() | String.t(), keyword() | map()) ::
          ElmUi.Widget.t()
  def presence_dot(id, status, opts \\ []) when is_atom(status) or is_binary(status) do
    opts = options(id, opts)

    widget(:presence_dot, opts,
      attributes: %{
        status: status,
        label: Builder.option(opts, :label),
        pulse: option(opts, :pulse, false),
        summary: Builder.option(opts, :summary)
      },
      metadata: %{native_surface: :portable_semantic, status?: true}
    )
  end

  @spec segmented_button_group(String.t() | atom(), term(), keyword() | map()) :: ElmUi.Widget.t()
  def segmented_button_group(id, items, opts \\ []) do
    opts = options(id, opts)

    widget(:segmented_button_group, opts,
      attributes: %{
        items: normalize_items(items),
        active_item: Builder.option(opts, :active_item),
        selection_mode: Builder.option(opts, :selection_mode, :single),
        orientation: Builder.option(opts, :orientation, :horizontal),
        summary: Builder.option(opts, :summary)
      },
      state: state(opts, [:disabled, :focused, :selected]),
      events: Builder.events(opts, on_select: :selection, on_change: :change),
      metadata: %{native_surface: :portable_semantic, selection?: true}
    )
  end

  @spec list_item_multi_column(String.t() | atom(), term(), keyword() | map()) :: ElmUi.Widget.t()
  def list_item_multi_column(id, columns, opts \\ []) do
    opts = options(id, opts)

    widget(:list_item_multi_column, opts,
      attributes: %{
        columns: normalize_items(columns),
        label: Builder.option(opts, :label),
        value: Builder.option(opts, :value),
        status: Builder.option(opts, :status),
        summary: Builder.option(opts, :summary)
      },
      metadata: %{native_surface: :portable_semantic, row?: true}
    )
  end

  @spec artifact_row(String.t() | atom(), term(), String.t(), keyword() | map()) ::
          ElmUi.Widget.t()
  def artifact_row(id, artifact, title, opts \\ []) when is_binary(title) do
    opts = options(id, opts)

    widget(:artifact_row, opts,
      attributes: %{
        artifact: artifact,
        title: title,
        status: Builder.option(opts, :status),
        timestamp: Builder.option(opts, :timestamp),
        summary: Builder.option(opts, :summary)
      },
      state: state(opts, [:disabled, :focused, :selected]),
      events: Builder.events(opts, on_click: :click, on_select: :selection),
      metadata: %{native_surface: :portable_semantic, row?: true}
    )
  end

  @spec sticky_header(String.t() | atom(), String.t(), keyword() | map()) :: ElmUi.Widget.t()
  def sticky_header(id, title, opts \\ []) when is_binary(title) do
    opts = options(id, opts)

    widget(:sticky_header, opts,
      attributes: %{
        title: title,
        elevation: Builder.option(opts, :elevation),
        summary: Builder.option(opts, :summary)
      },
      state: state(opts, [:disabled, :current], stuck: option(opts, :stuck, false)),
      metadata: %{native_surface: :portable_semantic, sticky?: true}
    )
  end

  @spec pipeline_stepper_horizontal(String.t() | atom(), term(), keyword() | map()) ::
          ElmUi.Widget.t()
  def pipeline_stepper_horizontal(id, steps, opts \\ []) do
    opts = options(id, opts)

    widget(:pipeline_stepper_horizontal, opts,
      attributes: %{
        steps: normalize_items(steps),
        active_item: Builder.option(opts, :active_item),
        status: Builder.option(opts, :status),
        orientation: :horizontal,
        summary: Builder.option(opts, :summary)
      },
      state: state(opts, [:disabled, :focused, :current]),
      metadata: %{native_surface: :portable_workflow, progress?: true}
    )
  end

  @spec segmented_progress_bar(String.t() | atom(), term(), keyword() | map()) :: ElmUi.Widget.t()
  def segmented_progress_bar(id, segments, opts \\ []) do
    opts = options(id, opts)

    widget(:segmented_progress_bar, opts,
      attributes: %{
        segments: normalize_items(segments),
        current: Builder.option(opts, :current),
        maximum: Builder.option(opts, :maximum, 100),
        label: Builder.option(opts, :label),
        summary: Builder.option(opts, :summary)
      },
      state: state(opts, [:disabled]),
      metadata: %{native_surface: :portable_workflow, progress?: true}
    )
  end

  @spec workflow_stage_list_vertical(String.t() | atom(), term(), keyword() | map()) ::
          ElmUi.Widget.t()
  def workflow_stage_list_vertical(id, stages, opts \\ []) do
    opts = options(id, opts)

    widget(:workflow_stage_list_vertical, opts,
      attributes: %{
        stages: normalize_items(stages),
        active_item: Builder.option(opts, :active_item),
        status: Builder.option(opts, :status),
        orientation: :vertical,
        summary: Builder.option(opts, :summary)
      },
      state: state(opts, [:disabled, :focused, :current]),
      metadata: %{native_surface: :portable_workflow, progress?: true}
    )
  end

  @spec meter_thin(String.t() | atom(), number(), keyword() | map()) :: ElmUi.Widget.t()
  def meter_thin(id, current, opts \\ []) when is_number(current) do
    opts = options(id, opts)

    widget(:meter_thin, opts,
      attributes: %{
        current: current,
        minimum: Builder.option(opts, :minimum, 0),
        maximum: Builder.option(opts, :maximum, 100),
        label: Builder.option(opts, :label),
        severity: Builder.option(opts, :severity),
        summary: Builder.option(opts, :summary)
      },
      state: state(opts, [:disabled]),
      metadata: %{native_surface: :portable_workflow, meter?: true}
    )
  end

  @spec slide_over_panel(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: ElmUi.Widget.t()
  def slide_over_panel(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(id, opts)

    widget(:slide_over_panel, opts,
      attributes: %{
        title: Builder.option(opts, :title),
        placement: Builder.option(opts, :placement, :end),
        modal: option(opts, :modal, true),
        summary: Builder.option(opts, :summary)
      },
      slot_children: %{content: Builder.children!(children)},
      state: state(opts, [:disabled, :focused, :open], visible: option(opts, :visible, false)),
      events: Builder.events(opts, on_open: :open, on_close: :close, on_dismiss: :dismiss),
      metadata: %{native_surface: :portable_workflow, overlay?: true}
    )
  end

  @spec event_callout(String.t() | atom(), String.t(), keyword() | map()) :: ElmUi.Widget.t()
  def event_callout(id, message, opts \\ []) when is_binary(message) do
    opts = options(id, opts)

    widget(:event_callout, opts,
      attributes: %{
        title: Builder.option(opts, :title),
        message: message,
        severity: Builder.option(opts, :severity, :info),
        timestamp: Builder.option(opts, :timestamp),
        summary: Builder.option(opts, :summary)
      },
      metadata: %{native_surface: :portable_workflow, callout?: true}
    )
  end

  @spec redline_inline(String.t() | atom(), String.t(), String.t(), keyword() | map()) ::
          ElmUi.Widget.t()
  def redline_inline(id, before_text, after_text, opts \\ [])
      when is_binary(before_text) and is_binary(after_text) do
    opts = options(id, opts)

    widget(:redline_inline, opts,
      attributes: %{
        before_text: before_text,
        after_text: after_text,
        label: Builder.option(opts, :label),
        summary: Builder.option(opts, :summary)
      },
      metadata: %{native_surface: :portable_workflow, diff?: true}
    )
  end

  @spec code_block_syntax_highlighted(String.t() | atom(), String.t(), keyword() | map()) ::
          ElmUi.Widget.t()
  def code_block_syntax_highlighted(id, code, opts \\ []) when is_binary(code) do
    opts = options(id, opts)

    widget(:code_block_syntax_highlighted, opts,
      attributes: %{
        code: code,
        language: Builder.option(opts, :language),
        label: Builder.option(opts, :label),
        wrap: option(opts, :wrap, false),
        summary: Builder.option(opts, :summary)
      },
      metadata: %{native_surface: :portable_workflow, document?: true}
    )
  end

  @spec chat_composer(String.t() | atom(), keyword() | map()) :: ElmUi.Widget.t()
  def chat_composer(id, opts \\ []) do
    opts = options(id, opts)

    widget(:chat_composer, opts,
      attributes: %{
        placeholder: Builder.option(opts, :placeholder),
        submit_intent: Builder.option(opts, :submit_intent),
        actions: normalize_items(Builder.option(opts, :actions, [])),
        multiline: option(opts, :multiline, true),
        summary: Builder.option(opts, :summary)
      },
      state: state(opts, [:disabled, :focused, :editing]),
      events: Builder.events(opts, on_change: :change, on_submit: :submit, on_command: :command),
      metadata: %{native_surface: :portable_workflow, composer?: true}
    )
  end

  @spec normalize_items(term()) :: [map()]
  def normalize_items(nil), do: []

  def normalize_items(items) when is_map(items) do
    items
    |> Map.to_list()
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> normalize_items()
  end

  def normalize_items(items) when is_list(items) do
    Enum.map(items, fn
      {id, value} ->
        %{id: id, label: label(value), value: value}

      item when is_map(item) ->
        %{}
        |> Builder.maybe_put(:id, option(item, :id, option(item, :value, option(item, :label))))
        |> Builder.maybe_put(:label, option(item, :label, label(option(item, :value, item))))
        |> Builder.maybe_put(:value, option(item, :value, item))
        |> Builder.maybe_put(:status, option(item, :status))
        |> Builder.maybe_put(:description, option(item, :description))

      value ->
        %{id: value, label: label(value), value: value}
    end)
  end

  def normalize_items(value), do: [%{id: :value, label: label(value), value: value}]

  defp widget(kind, opts, attrs) do
    Builder.widget(kind,
      id: Builder.option(opts, :id),
      attributes: attrs |> Keyword.get(:attributes, %{}) |> compact_map(),
      slot_children: Keyword.get(attrs, :slot_children, %{}),
      state: Keyword.get_lazy(attrs, :state, fn -> state(opts) end),
      styles: Builder.styles(opts),
      events: Keyword.get_lazy(attrs, :events, fn -> Builder.events(opts) end),
      metadata: Builder.metadata(opts, Keyword.fetch!(attrs, :metadata))
    )
  end

  defp options(id, opts) do
    opts
    |> Builder.options()
    |> Map.put(:id, id)
  end

  defp state(opts, keys \\ [:disabled, :focused], extras \\ []) do
    opts
    |> Builder.state(keys)
    |> Map.merge(extras |> Enum.reject(fn {_key, value} -> is_nil(value) end) |> Map.new())
    |> compact_map()
  end

  defp option(opts, key, default \\ nil), do: Builder.option(opts, key, default)

  defp label(nil), do: ""
  defp label(value) when is_binary(value), do: value
  defp label(value) when is_atom(value), do: Atom.to_string(value)
  defp label(value) when is_integer(value) or is_float(value), do: to_string(value)
  defp label(value), do: inspect(value)

  defp compact_map(map) do
    map
    |> Enum.reject(fn {_key, value} -> value in [nil, [], %{}] end)
    |> Map.new()
  end
end
