defmodule WebUi.Renderer.Canonical do
  @moduledoc """
  Deterministic canonical-to-native widget mapping for the `web_ui` scaffold.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias WebUi.Renderer.Error
  alias WebUi.Widgets

  @spec render(Element.t(), keyword()) :: {:ok, WebUi.Widget.t()} | {:error, Error.t()}
  def render(%Element{} = element, _opts \\ []) do
    do_render(element)
  end

  defp do_render(%Element{id: nil} = element), do: {:error, Error.missing_identity(element)}

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:text, "text"] do
    {:ok,
     Widgets.text(element.id, attr(element, :content, inspect(element.id)), base_opts(element))}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:label, "label"] do
    {:ok,
     Widgets.label(
       element.id,
       attr(element, :content, inspect(element.id)),
       Keyword.merge(base_opts(element),
         for: attr(element, :for),
         relationship: attr(element, :relationship, :label)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:icon, "icon"] do
    {:ok,
     Widgets.icon(
       element.id,
       attr(element, :name, attr(element, :icon, :unknown)),
       Keyword.merge(base_opts(element),
         set: attr(element, :set),
         fallback_text: attr(element, :fallback_text)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:image, "image"] do
    {:ok,
     Widgets.image(
       element.id,
       attr(element, :src, attr(element, :source, "")),
       Keyword.merge(base_opts(element),
         alt: attr(element, :alt, ""),
         fit: attr(element, :fit, :cover)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:button, "button"] do
    {:ok,
     Widgets.button(
       element.id,
       attr(element, :label, attr(element, :content, "Button")),
       base_opts(element)
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:link, "link"] do
    {:ok,
     Widgets.link(
       element.id,
       attr(element, :label, attr(element, :content, "Link")),
       attr(element, :href, "#"),
       Keyword.merge(base_opts(element), external: attr(element, :external, false))
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:separator, "separator"] do
    {:ok,
     Widgets.separator(
       element.id,
       Keyword.merge(base_opts(element),
         orientation: attr(element, :orientation, :horizontal),
         decorative: attr(element, :decorative, true)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:spacer, "spacer"] do
    {:ok,
     Widgets.spacer(
       element.id,
       Keyword.merge(base_opts(element),
         size: attr(element, :size, :md),
         grow: attr(element, :grow, 0)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:content, "content"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.content(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           role: attr(element, :role, :content),
           presentation: attr(element, :presentation, :body)
         )
       )}
    end
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:text_input, "text_input"] do
    {:ok,
     Widgets.text_input(
       element.id,
       Keyword.merge(base_opts(element),
         name: attr(element, :name),
         value: attr(element, :value, ""),
         placeholder: attr(element, :placeholder),
         multiline: attr(element, :multiline, false),
         input_mode: attr(element, :input_mode, :text)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:checkbox, "checkbox"] do
    {:ok,
     Widgets.checkbox(
       element.id,
       attr(element, :label, "Checkbox"),
       Keyword.merge(base_opts(element),
         name: attr(element, :name),
         checked: attr(element, :checked, attr(element, :value, false))
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:select, "select"] do
    {:ok,
     Widgets.select(
       element.id,
       attr(element, :options, []),
       Keyword.merge(base_opts(element),
         name: attr(element, :name),
         value: attr(element, :value),
         multiple: attr(element, :multiple, false)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:menu, "menu"] do
    {:ok,
     Widgets.menu(
       element.id,
       attr(element, :items, []),
       Keyword.merge(base_opts(element),
         active_item: attr(element, :active_item),
         orientation: attr(element, :orientation, :vertical)
       )
     )}
  end

  defp do_render(%Element{type: :widget, kind: kind} = element)
       when kind in [:tabs, "tabs"] do
    {:ok,
     Widgets.tabs(
       element.id,
       attr(element, :items, []),
       Keyword.merge(base_opts(element),
         active_item: attr(element, :active_item),
         orientation: attr(element, :orientation, :horizontal)
       )
     )}
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layout, "layout"] and kind in [:row, "row"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.row(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           gap: attr(element, :gap),
           align: attr(element, :align),
           justify: attr(element, :justify)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:layout, "layout"] and
              kind in [:column, "column", :stack, "stack", :container, "container"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.column(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           gap: attr(element, :gap),
           align: attr(element, :align),
           justify: attr(element, :justify)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and
              kind in [:form, "form", :form_builder, "form_builder"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.form(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           mode: attr(element, :mode, :grouped),
           autocomplete: attr(element, :autocomplete, true)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and kind in [:field_group, "field_group"] do
    with {:ok, children} <- map_children(default_children(element)) do
      {:ok,
       Widgets.field_group(
         element.id,
         children,
         Keyword.merge(base_opts(element),
           legend: attr(element, :legend),
           group_description: attr(element, :description),
           collapsible: attr(element, :collapsible, false)
         )
       )}
    end
  end

  defp do_render(%Element{type: type, kind: kind} = element)
       when type in [:composite, "composite"] and kind in [:field, "field"] do
    with {:ok, control} <- required_slot_child(element, :control) do
      {:ok,
       Widgets.field(
         element.id,
         control,
         Keyword.merge(base_opts(element),
           name: attr(element, :name),
           control_id: attr(element, :control_id),
           label: optional_slot_child(element, :label),
           help: optional_slot_child(element, :help)
         )
       )}
    end
  end

  defp do_render(%Element{} = element) do
    {:error, Error.unsupported_kind(element, WebUi.Renderer.supported_kinds())}
  end

  defp base_opts(%Element{} = element) do
    [
      description: element.metadata && element.metadata.description,
      metadata: %{
        canonical_source: %{
          id: element.id,
          type: element.type,
          kind: element.kind
        }
      }
    ]
    |> Enum.reject(fn {_key, value} -> value in [nil, %{}] end)
  end

  defp default_children(%Element{} = element) do
    element.children
    |> Enum.filter(&(&1.slot in [:default, "default"]))
  end

  defp map_children(children) do
    children
    |> Enum.reduce_while({:ok, []}, fn child, {:ok, acc} ->
      case render_child(child) do
        {:ok, widget} -> {:cont, {:ok, [widget | acc]}}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
    |> case do
      {:ok, widgets} -> {:ok, Enum.reverse(widgets)}
      error -> error
    end
  end

  defp required_slot_child(%Element{} = element, slot) do
    case optional_slot_child(element, slot) do
      nil -> {:error, Error.missing_required_slot(element, slot)}
      widget -> {:ok, widget}
    end
  end

  defp optional_slot_child(%Element{} = element, slot) do
    element.children
    |> Enum.find(&(&1.slot == slot))
    |> case do
      %Child{element: %Element{} = child} ->
        case do_render(child) do
          {:ok, widget} -> widget
          {:error, _error} -> nil
        end

      _other ->
        nil
    end
  end

  defp render_child(%Child{element: %Element{} = element}), do: do_render(element)
  defp render_child(%Element{} = element), do: do_render(element)

  defp attr(%Element{attributes: attrs}, key, default \\ nil) do
    Map.get(attrs, key) || Map.get(attrs, Atom.to_string(key)) || default
  end
end
