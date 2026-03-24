defmodule DesktopUi.Renderer.Mapper do
  @moduledoc """
  Canonical-to-native widget mapper for foundational `desktop_ui` rendering.
  """

  alias DesktopUi.Renderer.Error
  alias DesktopUi.Widget
  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child

  @spec map(Element.t(), keyword()) :: {:ok, Widget.t()} | {:error, Error.t()}
  def map(element, opts \\ [])

  def map(%Element{id: nil} = element, _opts) do
    {:error, Error.new(:missing_canonical_identity, %{kind: element.kind, type: element.type})}
  end

  def map(%Element{} = element, _opts) do
    with :ok <- validate_bindings(element),
         {:ok, slot_children} <- map_children(element.children),
         {:ok, widget} <- map_element(element) do
      {:ok, attach_slot_children(widget, slot_children)}
    end
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:text, "text"] do
    {:ok,
     DesktopUi.Widgets.text(
       element.id,
       content_text(element, to_string(element.id)),
       base_opts(element)
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:label, "label"] do
    {:ok,
     DesktopUi.Widgets.label(
       element.id,
       content_text(element, to_string(element.id)),
       base_opts(element)
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:icon, "icon"] do
    {:ok,
     DesktopUi.Widgets.icon(
       element.id,
       first_present(
         [group_attr(element, :icon, :name), attr(element, :icon), attr(element, :name)],
         :unknown
       ),
       Keyword.merge(
         base_opts(element),
         fallback_text:
           first_present(
             [group_attr(element, :icon, :fallback_text), attr(element, :fallback_text)],
             "[icon]"
           )
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:image, "image"] do
    {:ok,
     DesktopUi.Widgets.image(
       element.id,
       first_present(
         [group_attr(element, :image, :source), attr(element, :source), attr(element, :src)],
         ""
       ),
       Keyword.merge(
         base_opts(element),
         alt: first_present([group_attr(element, :image, :alt_text), attr(element, :alt)], "")
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:separator, "separator"] do
    {:ok,
     DesktopUi.Widgets.separator(
       element.id,
       Keyword.merge(
         base_opts(element),
         orientation:
           first_present(
             [group_attr(element, :separator, :orientation), attr(element, :orientation)],
             :horizontal
           )
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:spacer, "spacer"] do
    {:ok,
     DesktopUi.Widgets.spacer(
       element.id,
       Keyword.merge(base_opts(element),
         size: first_present([group_attr(element, :spacer, :size), attr(element, :size)], :md)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:button, "button"] do
    {:ok,
     DesktopUi.Widgets.button(
       element.id,
       content_text(element, "Button"),
       Keyword.merge(base_opts(element),
         on_click: interaction_payload(element, :click),
         intent: interaction_intent(element, :click)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:toggle, "toggle"] do
    {:ok,
     DesktopUi.Widgets.toggle(
       element.id,
       label_text(element, "Toggle"),
       Keyword.merge(
         base_opts(element),
         checked: first_present([attr(element, :checked), binding_value(element)], false),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change),
         intent: interaction_intent(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:link, "link"] do
    {:ok,
     DesktopUi.Widgets.link(
       element.id,
       label_text(element, "Link"),
       first_present(
         [group_attr(element, :link, :target), attr(element, :href), attr(element, :target)],
         "#"
       ),
       Keyword.merge(base_opts(element),
         on_follow: interaction_payload(element, :click),
         intent: interaction_intent(element, :click)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:command, "command"] do
    {:ok,
     DesktopUi.Widgets.command(
       element.id,
       label_text(element, "Command"),
       Keyword.merge(
         base_opts(element),
         shortcut:
           first_present([attr(element, :shortcut), group_attr(element, :command, :shortcut)]),
         on_press: interaction_payload(element, :command),
         intent: interaction_intent(element, :command)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:text_input, "text_input"] do
    {:ok,
     DesktopUi.Widgets.text_input(
       element.id,
       Keyword.merge(
         base_opts(element),
         value: first_present([attr(element, :value), binding_value(element)], ""),
         binding: binding_name(element),
         placeholder:
           first_present(
             [group_attr(element, :input, :placeholder), attr(element, :placeholder)],
             ""
           ),
         on_change: interaction_payload(element, :change),
         on_submit: interaction_payload(element, :submit)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:checkbox, "checkbox"] do
    {:ok,
     DesktopUi.Widgets.checkbox(
       element.id,
       label_text(element, "Checkbox"),
       Keyword.merge(
         base_opts(element),
         checked: first_present([attr(element, :checked), binding_value(element)], false),
         binding: binding_name(element),
         on_change: interaction_payload(element, :change)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:radio_group, "radio_group"] do
    {:ok,
     DesktopUi.Widgets.radio_group(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:select, "select"] do
    {:ok,
     DesktopUi.Widgets.select(
       element.id,
       first_present([group_attr(element, :selection, :options), attr(element, :options)], []),
       Keyword.merge(
         base_opts(element),
         selected: first_present([attr(element, :selected), binding_value(element)]),
         binding: binding_name(element),
         on_select: interaction_payload(element, :selection)
       )
     )}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:tabs, "tabs"] do
    {:ok, map_navigation(:tabs, element)}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:menu, "menu"] do
    {:ok, map_navigation(:menu, element)}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:breadcrumbs, "breadcrumbs"] do
    {:ok, map_navigation(:breadcrumbs, element)}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element) when kind in [:list, "list"] do
    {:ok, map_navigation(:list, element)}
  end

  defp map_element(%Element{type: :widget, kind: kind} = element)
       when kind in [:content, "content"] do
    {:ok, DesktopUi.Widgets.content(element.id, [], base_opts(element))}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element)
       when kind in [:column, "column"] do
    {:ok,
     DesktopUi.Widgets.column(
       element.id,
       [],
       Keyword.merge(base_opts(element), gap: first_present([attr(element, :gap)], 16))
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element) when kind in [:row, "row"] do
    {:ok,
     DesktopUi.Widgets.row(
       element.id,
       [],
       Keyword.merge(base_opts(element), gap: first_present([attr(element, :gap)], 12))
     )}
  end

  defp map_element(%Element{type: :layout, kind: kind} = element)
       when kind in [:stack, "stack"] do
    {:ok,
     DesktopUi.Widgets.stack(
       element.id,
       [],
       Keyword.merge(base_opts(element), align: first_present([attr(element, :align)], :stretch))
     )}
  end

  defp map_element(%Element{} = element) do
    {:error,
     Error.new(:unsupported_canonical_construct, %{
       kind: element.kind,
       type: element.type,
       id: element.id
     })}
  end

  defp map_children(children) do
    children
    |> Enum.reject(&is_nil(&1.element))
    |> Enum.reduce_while({:ok, %{}}, fn %Child{slot: slot, element: element}, {:ok, acc} ->
      case map(element) do
        {:ok, widget} ->
          {:cont, {:ok, Map.update(acc, slot, [widget], fn existing -> existing ++ [widget] end)}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
  end

  defp attach_slot_children(%Widget{} = widget, slot_children) do
    if map_size(slot_children) == 0 do
      widget
    else
      children = slot_children |> Map.values() |> List.flatten()
      %{widget | slot_children: slot_children, slots: Map.keys(slot_children), children: children}
    end
  end

  defp map_navigation(kind, element) do
    items = first_present([group_attr(element, :navigation, :items), attr(element, :items)], [])

    current =
      first_present([
        group_attr(element, :navigation, :active_item),
        attr(element, :current),
        binding_value(element)
      ])

    apply(DesktopUi.Widgets, kind, [
      element.id,
      items,
      Keyword.merge(
        base_opts(element),
        current: current,
        binding: binding_name(element),
        on_navigate: interaction_payload(element, :navigation),
        on_select: interaction_payload(element, :selection)
      )
    ])
  end

  defp validate_bindings(%Element{} = element) do
    bindings = [attr(element, :binding), attr(element, :bindings)] |> Enum.reject(&is_nil/1)

    if Enum.all?(bindings, &valid_binding_attachment?/1) do
      :ok
    else
      {:error, Error.new(:invalid_canonical_bindings, %{kind: element.kind, id: element.id})}
    end
  end

  defp valid_binding_attachment?(%{name: name}) when is_atom(name) or is_binary(name), do: true

  defp valid_binding_attachment?(bindings) when is_list(bindings) do
    Enum.all?(bindings, fn
      %{name: name} -> is_atom(name) or is_binary(name)
      _other -> false
    end)
  end

  defp valid_binding_attachment?(_other), do: false

  defp base_opts(element) do
    [
      styles: normalize_styles(attr(element, :styles)),
      metadata: metadata_opts(element),
      disabled:
        first_present([attr(element, :disabled), metadata_attr(element, :disabled)], false)
    ]
  end

  defp metadata_opts(element) do
    [
      label: label_text(element),
      description: metadata_attr(element, :description),
      variant: first_present([attr(element, :variant), metadata_attr(element, :variant)]),
      shortcut: first_present([attr(element, :shortcut), metadata_attr(element, :shortcut)]),
      focus_group: metadata_attr(element, :focus_group),
      binding_surface: metadata_attr(element, :binding_surface)
    ]
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
  end

  defp binding_name(element) do
    case attr(element, :binding) do
      %{name: name} -> name
      _other -> nil
    end
  end

  defp binding_value(element) do
    case attr(element, :binding) do
      %{value: value} -> value
      _other -> nil
    end
  end

  defp interaction_payload(element, family) do
    case attr(element, :interaction) do
      %{family: ^family} = interaction ->
        interaction

      %{kind: ^family} = interaction ->
        interaction

      %{intent: _intent} = interaction
      when family in [:click, :change, :submit, :selection, :navigation, :command] ->
        interaction

      _other ->
        case attr(element, :interactions) do
          interactions when is_list(interactions) ->
            Enum.find(interactions, fn
              %{family: ^family} -> true
              %{kind: ^family} -> true
              _ -> false
            end)

          _ ->
            nil
        end
    end
  end

  defp interaction_intent(element, family) do
    case interaction_payload(element, family) do
      %{intent: intent} -> intent
      _other -> family
    end
  end

  defp content_text(element, fallback) do
    first_present([attr(element, :content), attr(element, :text), label_text(element)], fallback)
  end

  defp label_text(element, fallback \\ nil) do
    first_present(
      [
        attr(element, :label),
        metadata_attr(element, :label),
        attr(element, :label_text),
        attr(element, :content)
      ],
      fallback
    )
  end

  defp group_attr(element, group, key) do
    case attr(element, group) do
      %{} = group_map -> Map.get(group_map, key) || Map.get(group_map, to_string(key))
      _other -> nil
    end
  end

  defp metadata_attr(%Element{} = element, key) do
    metadata = element.metadata || %{}
    Map.get(metadata, key) || Map.get(metadata, to_string(key))
  end

  defp attr(%Element{} = element, key) do
    Map.get(element.attributes, key) || Map.get(element.attributes, to_string(key))
  end

  defp first_present(values, fallback \\ nil) do
    Enum.find(values, fallback, &(not is_nil(&1)))
  end

  defp normalize_styles(nil), do: []
  defp normalize_styles(styles) when is_map(styles), do: Map.to_list(styles)
  defp normalize_styles(styles) when is_list(styles), do: styles
end
