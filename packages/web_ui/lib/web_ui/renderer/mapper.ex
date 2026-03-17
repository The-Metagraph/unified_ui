defmodule WebUi.Renderer.Mapper do
  @moduledoc false

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedIUR.Interaction
  alias WebUi.Renderer.Error
  alias WebUi.Widgets.{Forms, Foundational, Input, Layout, Navigation}

  @supported_kinds [
    :text,
    :label,
    :icon,
    :image,
    :button,
    :link,
    :separator,
    :spacer,
    :content,
    :text_input,
    :checkbox,
    :select,
    :menu,
    :tabs,
    :row,
    :column,
    :form_builder,
    :field_group,
    :field
  ]

  @spec supported_kinds() :: [atom()]
  def supported_kinds, do: @supported_kinds

  @spec element(Element.t()) :: {:ok, WebUi.Widget.t()} | {:error, Error.t()}
  def element(%Element{id: nil} = element), do: {:error, Error.missing_identity(element)}

  def element(%Element{type: :widget, kind: :text} = element) do
    {:ok, Foundational.text(content_text(element), base_opts(element))}
  end

  def element(%Element{type: :widget, kind: :label} = element) do
    {:ok,
     Foundational.label(
       content_text(element),
       base_opts(element)
       |> Map.put(:for, get_in(element.attributes, [:label, :for]))
       |> Map.put(:relationship, get_in(element.attributes, [:label, :relationship]))
     )}
  end

  def element(%Element{type: :widget, kind: :icon} = element) do
    {:ok,
     Foundational.icon(
       attribute(element, [:icon, :name]),
       merge_opts(base_opts(element), %{
         set: attribute(element, [:icon, :set]),
         fallback_text: attribute(element, [:icon, :fallback_text])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :image} = element) do
    {:ok,
     Foundational.image(
       attribute(element, [:image, :source]),
       merge_opts(base_opts(element), %{
         alt: attribute(element, [:image, :alt_text]),
         fit: attribute(element, [:image, :fit])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :button} = element) do
    {:ok,
     Foundational.button(
       content_text(element),
       merge_opts(base_opts(element), %{variant: style_variant(element)})
     )}
  end

  def element(%Element{type: :widget, kind: :link} = element) do
    {:ok,
     Foundational.link(
       content_text(element),
       attribute(element, [:link, :target]),
       merge_opts(base_opts(element), %{
         external?: attribute(element, [:link, :external?], false)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :separator} = element) do
    {:ok,
     Foundational.separator(
       merge_opts(base_opts(element), %{
         orientation: attribute(element, [:separator, :orientation]),
         decorative?: attribute(element, [:separator, :decorative?], true)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :spacer} = element) do
    {:ok,
     Foundational.spacer(
       merge_opts(base_opts(element), %{
         size: attribute(element, [:spacer, :size]),
         grow: attribute(element, [:spacer, :grow], 0),
         min: attribute(element, [:spacer, :min]),
         max: attribute(element, [:spacer, :max])
       })
     )}
  end

  def element(%Element{type: :widget, kind: :content} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Foundational.content(
         children,
         merge_opts(base_opts(element), %{
           role: attribute(element, [:container, :role]),
           presentation: attribute(element, [:container, :presentation])
         })
       )}
    end
  end

  def element(%Element{type: :widget, kind: :text_input} = element) do
    binding = first_binding(element)

    {:ok,
     Input.text_input(
       merge_opts(base_opts(element), %{
         name: Map.get(binding, :name),
         value: Map.get(binding, :value, Map.get(binding, :default, "")),
         placeholder: attribute(element, [:input, :placeholder]),
         multiline?: attribute(element, [:input, :multiline?], false),
         input_mode: attribute(element, [:input, :input_mode], :text)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :checkbox} = element) do
    binding = first_binding(element)

    {:ok,
     Input.checkbox(
       merge_opts(base_opts(element), %{
         name: Map.get(binding, :name),
         value: Map.get(binding, :value, false),
         checked?: Map.get(binding, :value, false),
         label: attribute(element, [:label, :text]),
         checked_value: attribute(element, [:input, :checked_value], true),
         unchecked_value: attribute(element, [:input, :unchecked_value], false)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :select} = element) do
    binding = first_binding(element)

    {:ok,
     Input.select(
       attribute(element, [:selection, :options], []),
       merge_opts(base_opts(element), %{
         name: Map.get(binding, :name),
         value: Map.get(binding, :value),
         multiple?: attribute(element, [:selection, :multiple?], false)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :menu} = element) do
    {:ok,
     Navigation.menu(
       attribute(element, [:navigation, :items], []),
       merge_opts(base_opts(element), %{
         active_item: attribute(element, [:navigation, :active_item]),
         orientation: attribute(element, [:navigation, :orientation], :vertical)
       })
     )}
  end

  def element(%Element{type: :widget, kind: :tabs} = element) do
    {:ok,
     Navigation.tabs(
       attribute(element, [:navigation, :items], []),
       merge_opts(base_opts(element), %{
         active_item: attribute(element, [:navigation, :active_item]),
         orientation: attribute(element, [:navigation, :orientation], :horizontal)
       })
     )}
  end

  def element(%Element{type: :layout, kind: :row} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Layout.row(
         children,
         merge_opts(base_opts(element), %{
           gap: attribute(element, [:layout, :gap]),
           align: attribute(element, [:layout, :align]),
           justify: attribute(element, [:layout, :justify])
         })
       )}
    end
  end

  def element(%Element{type: :layout, kind: :column} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Layout.column(
         children,
         merge_opts(base_opts(element), %{
           gap: attribute(element, [:layout, :gap]),
           align: attribute(element, [:layout, :align]),
           justify: attribute(element, [:layout, :justify])
         })
       )}
    end
  end

  def element(%Element{type: :composite, kind: :form_builder} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Forms.form_builder(
         children,
         merge_opts(base_opts(element), %{
           mode: attribute(element, [:form, :mode], :grouped),
           autocomplete?: attribute(element, [:form, :autocomplete?], true)
         })
       )}
    end
  end

  def element(%Element{type: :composite, kind: :field_group} = element) do
    with {:ok, children} <- map_children(child_elements(element)) do
      {:ok,
       Forms.field_group(
         children,
         merge_opts(base_opts(element), %{
           legend: attribute(element, [:group, :legend]),
           group_description: attribute(element, [:group, :description]),
           collapsible?: attribute(element, [:group, :collapsible?], false)
         })
       )}
    end
  end

  def element(%Element{type: :composite, kind: :field} = element) do
    with {:ok, control} <- required_slot_child(element, :control) do
      {:ok,
       Forms.field(
         control,
         merge_opts(base_opts(element), %{
           name: attribute(element, [:field, :name]),
           control_id: attribute(element, [:field, :control_id]),
           label: optional_slot_child(element, :label),
           help: optional_slot_child(element, :help)
         })
       )}
    end
  end

  def element(%Element{} = element) do
    {:error, Error.unsupported_kind(element, supported_kinds())}
  end

  defp base_opts(element) do
    %{
      id: element.id,
      description: element.metadata.description,
      tags: element.metadata.tags,
      annotations: element.metadata.annotations,
      style_hooks: style_hooks(element),
      state: canonical_state(element),
      events: canonical_events(element),
      metadata: canonical_metadata(element)
    }
  end

  defp canonical_metadata(element) do
    %{
      canonical_source: %{
        id: element.id,
        type: element.type,
        kind: element.kind
      },
      authored_ref: element.metadata.authored_ref,
      extra: element.metadata.extra,
      attachment_keys:
        element.attributes
        |> Map.keys()
        |> Enum.filter(&(&1 in [:style, :theme, :interactions, :bindings, :interaction_scope]))
        |> Enum.sort()
    }
  end

  defp canonical_state(element) do
    theme_state = get_in(element.attributes, [:theme, :state])

    element.attributes
    |> Map.get(:state, %{})
    |> normalize_map()
    |> maybe_put(:theme_state, theme_state)
  end

  defp canonical_events(element) do
    element.attributes
    |> Map.get(:interactions, [])
    |> Enum.reduce(%{}, fn %Interaction{} = interaction, acc ->
      Map.put(acc, event_name(element.kind, interaction.family), event_value(interaction))
    end)
  end

  defp event_name(kind, :selection) when kind in [:menu, :tabs], do: :navigation
  defp event_name(_kind, :selection), do: :change
  defp event_name(_kind, family), do: family

  defp event_value(%Interaction{} = interaction) do
    suffix = interaction.intent || Map.get(interaction.metadata, :phase) || interaction.family
    "canonical:#{suffix}"
  end

  defp style_hooks(element) do
    refs =
      element.attributes
      |> get_in([:theme, :token_refs])
      |> List.wrap()
      |> Enum.map(&token_ref_to_hook/1)

    refs
    |> maybe_append(style_tone(element))
    |> maybe_append(style_variant(element))
    |> Enum.uniq()
  end

  defp style_tone(element) do
    attribute(element, [:style, :emphasis, :tone])
  end

  defp style_variant(element) do
    attribute(element, [:theme, :variant])
  end

  defp token_ref_to_hook(%{path: path}) when is_list(path),
    do: path |> Enum.map(&to_string/1) |> Enum.join(".")

  defp token_ref_to_hook(value), do: to_string(value)

  defp content_text(element) do
    attribute(element, [:content, :text], "")
  end

  defp first_binding(element) do
    element.attributes
    |> Map.get(:bindings, [])
    |> List.first()
    |> normalize_map()
  end

  defp child_elements(element) do
    element.children
    |> Enum.filter(&Child.present?/1)
    |> Enum.map(& &1.element)
  end

  defp required_slot_child(element, slot) do
    case optional_slot_child(element, slot) do
      nil -> {:error, Error.invalid_field(element, slot)}
      widget -> {:ok, widget}
    end
  end

  defp optional_slot_child(element, slot) do
    element
    |> Element.children_for_slot(slot)
    |> Enum.find_value(fn
      %Child{element: nil} -> nil
      %Child{element: child} -> child |> element() |> unwrap_widget()
    end)
  end

  defp unwrap_widget({:ok, widget}), do: widget
  defp unwrap_widget({:error, _reason}), do: nil

  defp map_children(children) do
    children
    |> Enum.reduce_while({:ok, []}, fn child, {:ok, acc} ->
      case element(child) do
        {:ok, widget} -> {:cont, {:ok, acc ++ [widget]}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  defp normalize_map(nil), do: %{}
  defp normalize_map(%_{} = struct), do: Map.from_struct(struct)
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp maybe_append(list, nil), do: list
  defp maybe_append(list, value), do: list ++ [value]

  defp merge_opts(base, extras) do
    Map.merge(base, Enum.reject(extras, fn {_key, value} -> is_nil(value) end) |> Map.new())
  end

  defp attribute(%Element{attributes: attributes}, path, default \\ nil) do
    case get_in(attributes, path) do
      nil -> default
      value -> value
    end
  end
end
