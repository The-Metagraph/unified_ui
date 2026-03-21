defmodule WebUi.ServerRuntime.RenderModel do
  @moduledoc """
  Deterministic server-side render model generation for foundational `web_ui`
  widgets.
  """

  alias WebUi.Widget

  @spec build(Widget.t()) :: map()
  def build(%Widget{} = widget) do
    %{
      id: widget.id,
      family: widget.family,
      kind: widget.kind,
      dom: %{
        tag: dom_tag(widget.kind),
        role: dom_role(widget.kind),
        attributes: dom_attributes(widget)
      },
      attributes: widget.attributes,
      state: widget.state,
      styles: widget.styles,
      events: widget.events,
      metadata: widget.metadata,
      interactions: %{
        interactive?: widget.kind in interactive_kinds() or map_size(widget.events) > 0,
        focusable?: widget.kind in focusable_kinds(),
        editable?: widget.kind in editable_kinds(),
        navigable?: widget.kind in navigable_kinds()
      },
      slots:
        widget.slot_children
        |> Enum.sort_by(fn {slot, _children} -> to_string(slot) end)
        |> Enum.map(fn {slot, children} ->
          %{
            name: slot,
            children: Enum.map(children, &build/1)
          }
        end),
      diagnostics: %{
        event_names: widget.events |> Map.keys() |> Enum.sort(),
        slot_names: widget.slots |> Enum.map(&to_string/1) |> Enum.sort(),
        style_keys: widget.styles |> Map.keys() |> Enum.map(&to_string/1) |> Enum.sort()
      }
    }
  end

  defp dom_tag(:text), do: "span"
  defp dom_tag(:label), do: "label"
  defp dom_tag(:icon), do: "span"
  defp dom_tag(:image), do: "img"
  defp dom_tag(:button), do: "button"
  defp dom_tag(:link), do: "a"
  defp dom_tag(:separator), do: "hr"
  defp dom_tag(:spacer), do: "div"
  defp dom_tag(:content), do: "section"
  defp dom_tag(:text_input), do: "input"
  defp dom_tag(:checkbox), do: "input"
  defp dom_tag(:select), do: "select"
  defp dom_tag(:menu), do: "nav"
  defp dom_tag(:tabs), do: "div"
  defp dom_tag(:row), do: "div"
  defp dom_tag(:column), do: "div"
  defp dom_tag(:stack), do: "div"
  defp dom_tag(:panel), do: "section"
  defp dom_tag(:form), do: "form"
  defp dom_tag(:field_group), do: "fieldset"
  defp dom_tag(:field), do: "div"
  defp dom_tag(_kind), do: "div"

  defp dom_role(:text), do: "text"
  defp dom_role(:label), do: "label"
  defp dom_role(:button), do: "button"
  defp dom_role(:link), do: "link"
  defp dom_role(:text_input), do: "textbox"
  defp dom_role(:checkbox), do: "checkbox"
  defp dom_role(:select), do: "listbox"
  defp dom_role(:menu), do: "navigation"
  defp dom_role(:tabs), do: "tablist"
  defp dom_role(:form), do: "form"
  defp dom_role(:field_group), do: "group"
  defp dom_role(:field), do: "group"
  defp dom_role(:panel), do: "region"
  defp dom_role(_kind), do: "presentation"

  defp dom_attributes(%Widget{} = widget) do
    %{
      id: widget.id,
      class_tokens: List.wrap(widget.styles[:hooks]),
      disabled: Map.get(widget.state, :disabled, false)
    }
    |> maybe_put(:href, Map.get(widget.attributes, :href))
    |> maybe_put(:value, Map.get(widget.attributes, :value))
    |> maybe_put(:name, Map.get(widget.attributes, :name))
    |> maybe_put(:for, Map.get(widget.attributes, :for))
    |> maybe_put(:placeholder, Map.get(widget.attributes, :placeholder))
    |> maybe_put(:orientation, Map.get(widget.attributes, :orientation))
    |> maybe_put(:active_item, Map.get(widget.attributes, :active_item))
    |> maybe_put(:legend, Map.get(widget.attributes, :legend))
  end

  defp interactive_kinds do
    [:button, :link, :text_input, :checkbox, :select, :menu, :tabs, :form]
  end

  defp focusable_kinds do
    [:button, :link, :text_input, :checkbox, :select, :menu, :tabs]
  end

  defp editable_kinds do
    [:text_input, :checkbox, :select]
  end

  defp navigable_kinds do
    [:link, :menu, :tabs]
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
