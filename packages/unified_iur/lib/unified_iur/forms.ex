defmodule UnifiedIUR.Forms do
  @moduledoc """
  Canonical form-composition constructors for `UnifiedIUR`.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedIUR.Metadata
  alias UnifiedIUR.Widgets.Foundational

  @type opts :: keyword() | map()
  @type children_input ::
          [Child.t() | Element.t() | {Child.slot(), Element.t() | nil} | map()]

  @kinds [:form_builder, :field_group, :field]

  @spec kinds() :: [atom()]
  def kinds do
    @kinds
  end

  @spec form_builder(children_input(), opts()) :: Element.t()
  def form_builder(children \\ [], opts \\ []) when is_list(children) do
    opts = normalize_opts(opts)

    Element.new(:composite, :form_builder,
      id: option(opts, :id),
      metadata: normalize_metadata(opts),
      attributes:
        %{}
        |> merge_attribute(:form, %{
          mode: option(opts, :mode, :grouped),
          autocomplete?: option(opts, :autocomplete?, true)
        })
        |> merge_attribute(:binding, normalize_binding(opts))
        |> merge_attribute(:validation, normalize_validation(opts))
        |> merge_attribute(:submission, normalize_submission(opts))
        |> merge_attribute(:style, normalize_style(opts)),
      children: children
    )
  end

  @spec field_group(children_input(), opts()) :: Element.t()
  def field_group(children \\ [], opts \\ []) when is_list(children) do
    opts = normalize_opts(opts)

    Element.new(:composite, :field_group,
      id: option(opts, :id),
      metadata: normalize_metadata(opts),
      attributes:
        %{}
        |> merge_attribute(:group, %{
          legend: option(opts, :legend),
          description: option(opts, :group_description),
          role: option(opts, :role, :group),
          collapsible?: option(opts, :collapsible?, false)
        })
        |> merge_attribute(:binding, normalize_binding(opts))
        |> merge_attribute(:validation, normalize_validation(opts))
        |> merge_attribute(:style, normalize_style(opts)),
      children: children
    )
  end

  @spec field(Element.t(), opts()) :: Element.t()
  def field(%Element{} = control, opts \\ []) do
    opts = normalize_opts(opts)
    control_id = option(opts, :control_id, control.id)
    label_child = normalize_label_child(option(opts, :label), control_id)
    help_child = normalize_help_child(option(opts, :help))

    children =
      []
      |> maybe_append(label_child)
      |> Kernel.++([Child.new(:control, control)])
      |> maybe_append(help_child)

    Element.new(:composite, :field,
      id: option(opts, :id),
      metadata: normalize_metadata(opts),
      attributes:
        %{}
        |> merge_attribute(:field, %{
          name: option(opts, :name),
          control_id: control_id,
          label_slot: if(label_child, do: :label, else: nil),
          help_slot: if(help_child, do: :help, else: nil)
        })
        |> merge_attribute(:binding, normalize_binding(opts))
        |> merge_attribute(:validation, normalize_validation(opts))
        |> merge_attribute(:style, normalize_style(opts)),
      children: children
    )
  end

  defp normalize_label_child(nil, _control_id), do: nil

  defp normalize_label_child(%Element{} = label, _control_id) do
    Child.new(:label, label)
  end

  defp normalize_label_child(text, control_id) when is_binary(text) do
    Child.new(
      :label,
      Foundational.label(text,
        id: label_id(control_id),
        label: %{for: control_id, relationship: :field_label}
      )
    )
  end

  defp normalize_help_child(nil), do: nil
  defp normalize_help_child(%Element{} = help), do: Child.new(:help, help)

  defp normalize_help_child(text) when is_binary(text),
    do: Child.new(:help, Foundational.text(text))

  defp label_id(nil), do: nil
  defp label_id(control_id), do: "#{control_id}-label"

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

  defp normalize_binding(opts) do
    opts
    |> option(:binding, %{})
    |> normalize_map()
    |> maybe_put(:name, option(opts, :name))
    |> maybe_put(:path, option(opts, :path))
    |> maybe_put(:scope, option(opts, :scope))
    |> maybe_put(:value, option(opts, :value))
    |> maybe_put(:default, option(opts, :default))
  end

  defp normalize_validation(opts) do
    opts
    |> option(:validation, %{})
    |> normalize_map()
    |> maybe_put(:required?, option(opts, :required?))
    |> maybe_put(:errors, normalize_errors(option(opts, :errors)))
    |> maybe_put(:constraints, normalize_map(option(opts, :constraints, %{})))
    |> maybe_put(:status, option(opts, :status))
  end

  defp normalize_submission(opts) do
    opts
    |> option(:submission, %{})
    |> normalize_map()
    |> maybe_put(:intent, option(opts, :submit_intent))
    |> maybe_put(:method, option(opts, :submit_method, :signal))
    |> maybe_put(:trigger, option(opts, :submit_trigger, :submit))
    |> maybe_put(:allow_partial?, option(opts, :allow_partial?))
  end

  defp normalize_style(opts) do
    style_refs =
      opts
      |> option(:style_refs, [])
      |> List.wrap()
      |> Enum.reject(&is_nil/1)

    opts
    |> option(:style, %{})
    |> normalize_map()
    |> maybe_put(:style_refs, if(style_refs == [], do: nil, else: style_refs))
    |> maybe_put(:variant, option(opts, :variant))
    |> maybe_put(:tone, option(opts, :tone))
  end

  defp normalize_errors(nil), do: nil
  defp normalize_errors(errors) when is_list(errors), do: Enum.reject(errors, &is_nil/1)

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp normalize_opts(opts) when is_list(opts), do: Enum.into(opts, %{})
  defp normalize_opts(opts) when is_map(opts), do: Map.new(opts)

  defp option(opts, key, default \\ nil) do
    Map.get(opts, key, Map.get(opts, Atom.to_string(key), default))
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp maybe_append(list, nil), do: list
  defp maybe_append(list, item), do: list ++ [item]

  defp merge_attribute(attributes, _key, value) when value in [%{}, [], nil], do: attributes
  defp merge_attribute(attributes, key, value), do: Map.put(attributes, key, value)
end
