defmodule UnifiedIUR.Widgets.Workflow do
  @moduledoc """
  Canonical constructors for portable workflow, document, and composer widgets.
  """

  alias UnifiedIUR.Attachment
  alias UnifiedIUR.Element
  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Metadata

  @type opts :: keyword() | map()
  @type children_input ::
          [
            UnifiedIUR.Element.Child.t()
            | Element.t()
            | {atom() | String.t(), Element.t() | nil}
            | map()
          ]

  @type widget_kind ::
          :pipeline_stepper_horizontal
          | :segmented_progress_bar
          | :workflow_stage_list_vertical
          | :meter_thin
          | :slide_over_panel
          | :event_callout
          | :redline_inline
          | :code_block_syntax_highlighted
          | :chat_composer

  @kinds [
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

  @spec kinds() :: [widget_kind()]
  def kinds do
    @kinds
  end

  @spec pipeline_stepper_horizontal(keyword() | map() | list(), opts()) :: Element.t()
  def pipeline_stepper_horizontal(steps, opts \\ []) when is_list(steps) or is_map(steps) do
    opts = normalize_opts(opts)
    normalized_steps = normalize_named_items(steps)

    build_widget(
      :pipeline_stepper_horizontal,
      :workflow,
      %{}
      |> maybe_put(:variant, :pipeline_stepper)
      |> maybe_put(:orientation, :horizontal)
      |> maybe_put(:steps, normalized_steps)
      |> maybe_put(:active_item, option(opts, :active_item))
      |> maybe_put(:status, option(opts, :status))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{items: normalized_steps}
    )
  end

  @spec segmented_progress_bar(keyword() | map() | list(), opts()) :: Element.t()
  def segmented_progress_bar(segments, opts \\ []) when is_list(segments) or is_map(segments) do
    opts = normalize_opts(opts)
    normalized_segments = normalize_named_items(segments)

    build_widget(
      :segmented_progress_bar,
      :progress,
      %{}
      |> maybe_put(:variant, :segmented)
      |> maybe_put(:segments, normalized_segments)
      |> maybe_put(:current, option(opts, :current))
      |> maybe_put(:maximum, option(opts, :maximum, 100))
      |> maybe_put(:label, option(opts, :label))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{label: option(opts, :label)}
    )
  end

  @spec workflow_stage_list_vertical(keyword() | map() | list(), opts()) :: Element.t()
  def workflow_stage_list_vertical(stages, opts \\ []) when is_list(stages) or is_map(stages) do
    opts = normalize_opts(opts)
    normalized_stages = normalize_named_items(stages)

    build_widget(
      :workflow_stage_list_vertical,
      :workflow,
      %{}
      |> maybe_put(:variant, :stage_list)
      |> maybe_put(:orientation, :vertical)
      |> maybe_put(:stages, normalized_stages)
      |> maybe_put(:active_item, option(opts, :active_item))
      |> maybe_put(:status, option(opts, :status))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{items: normalized_stages}
    )
  end

  @spec meter_thin(integer() | float(), opts()) :: Element.t()
  def meter_thin(current, opts \\ []) when is_number(current) do
    opts = normalize_opts(opts)

    build_widget(
      :meter_thin,
      :meter,
      %{}
      |> maybe_put(:variant, :thin)
      |> maybe_put(:current, current)
      |> maybe_put(:minimum, option(opts, :minimum, 0))
      |> maybe_put(:maximum, option(opts, :maximum, 100))
      |> maybe_put(:label, option(opts, :label))
      |> maybe_put(:severity, option(opts, :severity))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{label: option(opts, :label)}
    )
  end

  @spec slide_over_panel(children_input(), opts()) :: Element.t()
  def slide_over_panel(children \\ [], opts \\ []) when is_list(children) do
    opts = normalize_opts(opts)

    build_widget(
      :slide_over_panel,
      :panel,
      %{}
      |> maybe_put(:variant, :slide_over)
      |> maybe_put(:title, option(opts, :title))
      |> maybe_put(:placement, option(opts, :placement, :end))
      |> maybe_put(:visible?, option(opts, :visible?, false))
      |> maybe_put(:modal?, option(opts, :modal?, true))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{title: option(opts, :title)},
      children: children
    )
  end

  @spec event_callout(String.t(), opts()) :: Element.t()
  def event_callout(message, opts \\ []) when is_binary(message) do
    opts = normalize_opts(opts)

    build_widget(
      :event_callout,
      :callout,
      %{}
      |> maybe_put(:title, option(opts, :title))
      |> maybe_put(:message, message)
      |> maybe_put(:severity, option(opts, :severity, :info))
      |> maybe_put(:timestamp, option(opts, :timestamp))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{title: option(opts, :title), message: message}
    )
  end

  @spec redline_inline(String.t(), String.t(), opts()) :: Element.t()
  def redline_inline(before_text, after_text, opts \\ [])
      when is_binary(before_text) and is_binary(after_text) do
    opts = normalize_opts(opts)

    build_widget(
      :redline_inline,
      :redline,
      %{}
      |> maybe_put(:variant, :inline)
      |> maybe_put(:before_text, before_text)
      |> maybe_put(:after_text, after_text)
      |> maybe_put(:label, option(opts, :label))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{before_text: before_text, after_text: after_text, label: option(opts, :label)}
    )
  end

  @spec code_block_syntax_highlighted(String.t(), opts()) :: Element.t()
  def code_block_syntax_highlighted(code, opts \\ []) when is_binary(code) do
    opts = normalize_opts(opts)

    build_widget(
      :code_block_syntax_highlighted,
      :code_block,
      %{}
      |> maybe_put(:code, code)
      |> maybe_put(:language, option(opts, :language))
      |> maybe_put(:label, option(opts, :label))
      |> maybe_put(:wrap?, option(opts, :wrap?, false))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{code: code, label: option(opts, :label)}
    )
  end

  @spec chat_composer(opts()) :: Element.t()
  def chat_composer(opts \\ []) do
    opts = normalize_opts(opts)
    actions = normalize_named_items(option(opts, :actions, []))

    build_widget(
      :chat_composer,
      :composer,
      %{}
      |> maybe_put(:placeholder, option(opts, :placeholder))
      |> maybe_put(:submit_intent, option(opts, :submit_intent))
      |> maybe_put(:actions, actions)
      |> maybe_put(:multiline?, option(opts, :multiline?, true))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{placeholder: option(opts, :placeholder)}
    )
  end

  defp build_widget(kind, attribute_key, payload, opts, build_opts) do
    opts = normalize_opts(opts)

    Element.new(:widget, kind,
      id: option(opts, :id),
      metadata: normalize_metadata(opts),
      attributes:
        %{}
        |> merge_attribute(attribute_key, compact_map(payload))
        |> merge_attribute(:content, build_opts |> Keyword.get(:content, %{}) |> compact_map())
        |> merge_attribute(:accessibility, normalize_accessibility(opts))
        |> merge_attribute(:state, normalize_state(opts))
        |> Attachment.merge(opts,
          component: kind,
          tone: option(opts, :tone),
          local_style: option(opts, :style),
          fallback_interactions: default_interactions(kind, payload, opts)
        ),
      children: Keyword.get(build_opts, :children, [])
    )
  end

  defp default_interactions(:chat_composer, payload, opts) do
    case Map.get(payload, :submit_intent) do
      nil ->
        []

      intent ->
        [
          Interaction.submit(
            intent: intent,
            element_id: option(opts, :id),
            phase: :submit,
            mapping: option(opts, :payload_mapping)
          )
        ]
    end
  end

  defp default_interactions(:slide_over_panel, payload, opts) do
    intent = option(opts, :visibility_intent)

    if is_nil(intent) do
      []
    else
      [
        Interaction.new(%{
          family: if(Map.get(payload, :visible?, false), do: :open, else: :close),
          intent: intent,
          source: %{element_id: option(opts, :id)},
          payload: %{visible?: Map.get(payload, :visible?, false)}
        })
      ]
    end
  end

  defp default_interactions(_kind, _payload, _opts), do: []

  defp normalize_metadata(opts) do
    opts
    |> option(:metadata)
    |> Metadata.merge(%{
      authored_ref: option(opts, :authored_ref),
      description: option(opts, :description),
      annotations: option(opts, :annotations, %{}),
      tags: option(opts, :tags, []),
      extra: option(opts, :extra, %{})
    })
  end

  defp normalize_accessibility(opts) do
    opts
    |> option(:accessibility, %{})
    |> normalize_map()
    |> maybe_put(:label, option(opts, :accessibility_label))
    |> maybe_put(:description, option(opts, :accessibility_description))
    |> maybe_put(:role_description, option(opts, :role_description))
    |> maybe_put(:hidden?, option(opts, :accessibility_hidden?))
  end

  defp normalize_state(opts) do
    opts
    |> option(:state, %{})
    |> normalize_map()
    |> maybe_put(:disabled?, option(opts, :disabled?))
    |> maybe_put(:active?, option(opts, :active?))
    |> maybe_put(:selected?, option(opts, :selected?))
    |> maybe_put(:current?, option(opts, :current?))
    |> maybe_put(:emphasis, option(opts, :emphasis))
  end

  defp normalize_named_items(items) when is_map(items) do
    items
    |> Map.to_list()
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> normalize_named_items()
  end

  defp normalize_named_items(items) when is_list(items) do
    Enum.map(items, fn
      {id, value} ->
        %{}
        |> maybe_put(:id, id)
        |> maybe_put(:label, label_from_value(value))
        |> maybe_put(:value, normalize_value(value))

      item when is_list(item) or is_map(item) ->
        item
        |> normalize_opts()
        |> normalize_value()

      value ->
        %{id: value, label: label_from_value(value), value: value}
    end)
  end

  defp label_from_value(value) when is_binary(value), do: value
  defp label_from_value(value) when is_atom(value), do: Atom.to_string(value)
  defp label_from_value(_value), do: nil

  defp normalize_value(value) when is_list(value) do
    if Keyword.keyword?(value) do
      value
      |> Enum.map(fn {key, nested_value} -> {key, normalize_value(nested_value)} end)
      |> Map.new()
    else
      Enum.map(value, &normalize_value/1)
    end
  end

  defp normalize_value(value) when is_map(value) do
    value
    |> Map.new(fn {key, nested_value} -> {key, normalize_value(nested_value)} end)
    |> compact_map()
  end

  defp normalize_value(value), do: value

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp normalize_opts(opts) when is_list(opts), do: Enum.into(opts, %{})
  defp normalize_opts(opts) when is_map(opts), do: Map.new(opts)

  defp option(opts, key, default \\ nil) do
    Map.get(opts, key, Map.get(opts, Atom.to_string(key), default))
  end

  defp compact_map(map) do
    map
    |> Enum.reject(fn {_key, value} -> value in [nil, %{}, []] end)
    |> Map.new()
  end

  defp merge_attribute(attributes, _key, value) when value in [%{}, [], nil], do: attributes
  defp merge_attribute(attributes, key, value), do: Map.put(attributes, key, value)

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
