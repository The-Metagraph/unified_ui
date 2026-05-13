defmodule UnifiedIUR.Widgets.Semantic do
  @moduledoc """
  Canonical constructors for portable semantic and micro-interaction widgets.
  """

  alias UnifiedIUR.Attachment
  alias UnifiedIUR.Element
  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Metadata

  @type opts :: keyword() | map()

  @type widget_kind ::
          :disclosure
          | :kicker
          | :avatar
          | :presence_dot
          | :segmented_button_group
          | :list_item_multi_column
          | :artifact_row
          | :sticky_header

  @kinds [
    :disclosure,
    :kicker,
    :avatar,
    :presence_dot,
    :segmented_button_group,
    :list_item_multi_column,
    :artifact_row,
    :sticky_header
  ]

  @spec kinds() :: [widget_kind()]
  def kinds do
    @kinds
  end

  @spec disclosure(String.t(), opts()) :: Element.t()
  def disclosure(label, opts \\ []) when is_binary(label) do
    opts = normalize_opts(opts)

    build_widget(
      :disclosure,
      :disclosure,
      %{}
      |> maybe_put(:label, label)
      |> maybe_put(:open?, option(opts, :open?, false))
      |> maybe_put(:content_label, option(opts, :content_label))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{label: label, expanded_label: option(opts, :content_label)}
    )
  end

  @spec kicker(String.t(), opts()) :: Element.t()
  def kicker(value, opts \\ []) when is_binary(value) do
    opts = normalize_opts(opts)

    build_widget(
      :kicker,
      :kicker,
      %{}
      |> maybe_put(:value, value)
      |> maybe_put(:icon, option(opts, :icon))
      |> maybe_put(:role, option(opts, :role, :eyebrow))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{text: value}
    )
  end

  @spec avatar(String.t(), opts()) :: Element.t()
  def avatar(label, opts \\ []) when is_binary(label) do
    opts = normalize_opts(opts)

    build_widget(
      :avatar,
      :avatar,
      %{}
      |> maybe_put(:label, label)
      |> maybe_put(:initials, option(opts, :initials))
      |> maybe_put(:source, option(opts, :avatar_source, option(opts, :source)))
      |> maybe_put(:status, option(opts, :status))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{label: label}
    )
  end

  @spec presence_dot(atom() | String.t(), opts()) :: Element.t()
  def presence_dot(status, opts \\ []) when is_atom(status) or is_binary(status) do
    opts = normalize_opts(opts)

    build_widget(
      :presence_dot,
      :presence,
      %{}
      |> maybe_put(:status, status)
      |> maybe_put(:label, option(opts, :label))
      |> maybe_put(:pulse?, option(opts, :pulse?, false))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{label: option(opts, :label)}
    )
  end

  @spec segmented_button_group(keyword() | map() | list(), opts()) :: Element.t()
  def segmented_button_group(items, opts \\ []) when is_list(items) or is_map(items) do
    opts = normalize_opts(opts)
    normalized_items = normalize_named_items(items)

    build_widget(
      :segmented_button_group,
      :segments,
      %{}
      |> maybe_put(:items, normalized_items)
      |> maybe_put(:active_item, option(opts, :active_item))
      |> maybe_put(:selection_mode, option(opts, :selection_mode, :single))
      |> maybe_put(:orientation, option(opts, :orientation, :horizontal))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{items: normalized_items}
    )
  end

  @spec list_item_multi_column(keyword() | map() | list(), opts()) :: Element.t()
  def list_item_multi_column(columns, opts \\ []) when is_list(columns) or is_map(columns) do
    opts = normalize_opts(opts)
    normalized_columns = normalize_named_items(columns)

    build_widget(
      :list_item_multi_column,
      :list_item,
      %{}
      |> maybe_put(:columns, normalized_columns)
      |> maybe_put(:label, option(opts, :label))
      |> maybe_put(:value, option(opts, :value))
      |> maybe_put(:status, option(opts, :status))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{label: option(opts, :label), value: option(opts, :value)}
    )
  end

  @spec artifact_row(term(), String.t(), opts()) :: Element.t()
  def artifact_row(artifact, title, opts \\ []) when is_binary(title) do
    opts = normalize_opts(opts)

    build_widget(
      :artifact_row,
      :artifact,
      %{}
      |> maybe_put(:value, normalize_value(artifact))
      |> maybe_put(:title, title)
      |> maybe_put(:status, option(opts, :status))
      |> maybe_put(:timestamp, option(opts, :timestamp))
      |> maybe_put(:action_intent, option(opts, :action_intent))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{title: title}
    )
  end

  @spec sticky_header(String.t(), opts()) :: Element.t()
  def sticky_header(title, opts \\ []) when is_binary(title) do
    opts = normalize_opts(opts)

    build_widget(
      :sticky_header,
      :sticky_header,
      %{}
      |> maybe_put(:title, title)
      |> maybe_put(:stuck?, option(opts, :stuck?, false))
      |> maybe_put(:elevation, option(opts, :elevation))
      |> maybe_put(:summary, option(opts, :summary)),
      opts,
      content: %{title: title}
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
      children: []
    )
  end

  defp default_interactions(:artifact_row, payload, opts) do
    case Map.get(payload, :action_intent) do
      nil ->
        []

      intent ->
        [
          Interaction.click(
            intent: intent,
            element_id: option(opts, :id),
            value: Map.get(payload, :value),
            mapping: option(opts, :payload_mapping)
          )
        ]
    end
  end

  defp default_interactions(:segmented_button_group, payload, opts) do
    intent = option(opts, :selection_intent, option(opts, :action_intent))

    if is_nil(intent) do
      []
    else
      [
        Interaction.selection(
          intent: intent,
          element_id: option(opts, :id),
          selection: Map.get(payload, :active_item),
          mapping: option(opts, :payload_mapping)
        )
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
        %{value: normalize_value(value)}
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
